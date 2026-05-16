import Flutter
import HealthKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.gymapp.health/apple_health"
  private let formatter = ISO8601DateFormatter()
  private lazy var healthService = AppleHealthService(healthStore: HKHealthStore(), formatter: formatter)

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { [weak self] call, result in
        self?.handleHealthCall(call, result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleHealthCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isHealthDataAvailable":
      result(HKHealthStore.isHealthDataAvailable())
    case "requestAuthorization":
      healthService.requestAuthorization(result: result)
    case "getAuthorizationStatus":
      result(healthService.authorizationStatus())
    case "syncWorkouts":
      healthService.syncWorkouts(anchorData: nil, result: result)
    case "syncWorkoutsSince":
      let args = call.arguments as? [String: Any]
      healthService.syncWorkouts(anchorData: args?["anchorData"] as? String, result: result)
    case "getRecentWorkouts":
      healthService.fetchRecentWorkouts(days: 30, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

private final class AppleHealthService {
  init(healthStore: HKHealthStore, formatter: ISO8601DateFormatter) {
    self.healthStore = healthStore
    self.formatter = formatter
  }

  private let healthStore: HKHealthStore
  private let formatter: ISO8601DateFormatter

  func requestAuthorization(result: @escaping FlutterResult) {
    guard HKHealthStore.isHealthDataAvailable() else {
      result(false)
      return
    }

    guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
          let distanceWalkingRunningType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
          let distanceCyclingType = HKObjectType.quantityType(forIdentifier: .distanceCycling),
          let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)
    else {
      result(false)
      return
    }

    let readTypes: Set<HKObjectType> = [
      HKObjectType.workoutType(),
      activeEnergyType,
      distanceWalkingRunningType,
      distanceCyclingType,
      heartRateType,
    ]

    healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
      DispatchQueue.main.async {
        if let error {
          result(FlutterError(code: "authorization_failed", message: error.localizedDescription, details: nil))
        } else {
          result(success)
        }
      }
    }
  }

  func authorizationStatus() -> String {
    guard HKHealthStore.isHealthDataAvailable() else { return "unavailable" }
    switch healthStore.authorizationStatus(for: HKObjectType.workoutType()) {
    case .notDetermined:
      return "notDetermined"
    case .sharingDenied:
      return "sharingDenied"
    case .sharingAuthorized:
      return "authorized"
    @unknown default:
      return "unknown"
    }
  }

  func fetchRecentWorkouts(days: Int, result: @escaping FlutterResult) {
    executeWorkoutSampleQuery(startDate: Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date(), result: result)
  }

  func syncWorkouts(anchorData: String?, result: @escaping FlutterResult) {
    guard HKHealthStore.isHealthDataAvailable() else {
      result([
        "workouts": [],
        "anchorData": NSNull(),
      ])
      return
    }

    let predicateStart = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
    let predicate = HKQuery.predicateForSamples(withStart: predicateStart, end: nil, options: .strictStartDate)
    let anchor = decodeAnchor(from: anchorData)

    let query = HKAnchoredObjectQuery(type: HKObjectType.workoutType(), predicate: predicate, anchor: anchor, limit: HKObjectQueryNoLimit) {
      [weak self] _, samples, _, newAnchor, error in
      guard let self else { return }
      DispatchQueue.main.async {
        if let error {
          result(FlutterError(code: "sync_failed", message: error.localizedDescription, details: nil))
          return
        }
        let workouts = (samples as? [HKWorkout] ?? []).map(self.serializeWorkout(_:))
        result([
          "workouts": workouts,
          "anchorData": self.encodeAnchor(newAnchor),
        ])
      }
    }

    healthStore.execute(query)
  }

  private func executeWorkoutSampleQuery(startDate: Date, result: @escaping FlutterResult) {
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
    let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sort]) {
      [weak self] _, samples, error in
      guard let self else { return }
      DispatchQueue.main.async {
        if let error {
          result(FlutterError(code: "recent_workouts_failed", message: error.localizedDescription, details: nil))
          return
        }
        let workouts = (samples as? [HKWorkout] ?? []).map(self.serializeWorkout(_:))
        result(workouts)
      }
    }
    healthStore.execute(query)
  }

  private func serializeWorkout(_ workout: HKWorkout) -> [String: Any] {
    let rawMetadata = workout.metadata?.reduce(into: [String: String]()) { partialResult, item in
      partialResult[item.key] = "\(item.value)"
    } ?? [:]

    var payload: [String: Any] = [
      "externalId": workout.uuid.uuidString.lowercased(),
      "platform": "apple_health",
      "sourceName": workout.device?.name ?? workout.sourceRevision.source.name,
      "activityType": activityTypeName(for: workout.workoutActivityType),
      "startTime": formatter.string(from: workout.startDate),
      "endTime": formatter.string(from: workout.endDate),
      "durationSeconds": Int(workout.duration.rounded()),
      "rawPayload": [
        "sourceBundleIdentifier": workout.sourceRevision.source.bundleIdentifier,
        "sourceName": workout.sourceRevision.source.name,
        "deviceName": workout.device?.name as Any,
        "metadata": rawMetadata,
      ],
    ]

    if let energy = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
      payload["activeEnergyKcal"] = energy
    }
    if let distance = workout.totalDistance?.doubleValue(for: .meter()) {
      payload["distanceMeters"] = distance
    }

    // TODO: Use HKStatisticsQuery over heart-rate samples inside the workout interval to populate average and max BPM.
    payload["averageHeartRate"] = NSNull()
    payload["maxHeartRate"] = NSNull()

    return payload
  }

  private func activityTypeName(for type: HKWorkoutActivityType) -> String {
    switch type {
    case .running:
      return "running"
    case .walking:
      return "walking"
    case .cycling:
      return "cycling"
    case .traditionalStrengthTraining:
      return "traditional_strength_training"
    case .functionalStrengthTraining:
      return "functional_strength_training"
    case .highIntensityIntervalTraining:
      return "high_intensity_interval_training"
    case .yoga:
      return "yoga"
    case .hiking:
      return "hiking"
    case .swimming:
      return "swimming"
    default:
      return "activity_\(type.rawValue)"
    }
  }

  private func decodeAnchor(from base64: String?) -> HKQueryAnchor? {
    guard let base64, let data = Data(base64Encoded: base64) else { return nil }
    do {
      return try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
    } catch {
      return nil
    }
  }

  private func encodeAnchor(_ anchor: HKQueryAnchor?) -> String? {
    guard let anchor else { return nil }
    do {
      let data = try NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
      return data.base64EncodedString()
    } catch {
      return nil
    }
  }
}
