import 'dart:io';

import '../domain/device_integration_repository.dart';
import '../domain/fitness_provider.dart';
import 'apple_health/apple_health_data_source.dart';
import 'mock/mock_fitness_data_source.dart';

class DeviceIntegrationRepositoryImpl implements DeviceIntegrationRepository {
  DeviceIntegrationRepositoryImpl(
      this._appleHealthDataSource, this._mockDataSource);

  final AppleHealthDataSource _appleHealthDataSource;
  final MockFitnessDataSource _mockDataSource;

  @override
  Future<DeviceConnectionInfo> connect(FitnessProviderType provider) async {
    if (provider != FitnessProviderType.appleHealth) {
      // TODO(z33p): Replace this placeholder with real Health Connect and Garmin authorization flows.
      return DeviceConnectionInfo(
        provider: provider,
        available: Platform.isAndroid,
        connected: false,
        permissionStatus: 'coming_soon',
        isPreviewMode: false,
        message:
            '${provider.label} integration is planned for a future release.',
      );
    }

    final available = await _appleHealthDataSource.isAvailable();
    if (!available) {
      await _mockDataSource.requestAuthorization();
      return const DeviceConnectionInfo(
        provider: FitnessProviderType.appleHealth,
        available: false,
        connected: true,
        permissionStatus: 'preview',
        isPreviewMode: true,
        message:
            'HealthKit is unavailable here, so GymApp will use preview workouts.',
      );
    }

    final granted = await _appleHealthDataSource.requestAuthorization();
    final status = await _appleHealthDataSource.getAuthorizationStatus();
    return DeviceConnectionInfo(
      provider: FitnessProviderType.appleHealth,
      available: true,
      connected: granted,
      permissionStatus: status,
      isPreviewMode: false,
      message: granted
          ? 'Apple Health connected.'
          : 'Apple Health permission was not granted.',
    );
  }

  @override
  Future<DeviceConnectionInfo> getConnectionInfo(
      FitnessProviderType provider) async {
    if (provider == FitnessProviderType.healthConnect ||
        provider == FitnessProviderType.garmin) {
      // TODO(z33p): Surface native Health Connect and Garmin connection state when those integrations ship.
      return DeviceConnectionInfo(
        provider: provider,
        available:
            provider == FitnessProviderType.healthConnect && Platform.isAndroid,
        connected: false,
        permissionStatus: 'coming_soon',
        isPreviewMode: false,
        message: '${provider.label} support is coming soon.',
      );
    }

    if (provider == FitnessProviderType.appleHealth) {
      final available = await _appleHealthDataSource.isAvailable();
      if (!available) {
        return const DeviceConnectionInfo(
          provider: FitnessProviderType.appleHealth,
          available: false,
          connected: true,
          permissionStatus: 'preview',
          isPreviewMode: true,
          message:
              'Preview mode is active because HealthKit is unavailable on this device.',
        );
      }
      final status = await _appleHealthDataSource.getAuthorizationStatus();
      return DeviceConnectionInfo(
        provider: provider,
        available: true,
        connected: status == 'authorized' || status == 'sharingAuthorized',
        permissionStatus: status,
        isPreviewMode: false,
        message: status == 'authorized'
            ? 'Apple Health connected.'
            : 'Connect Apple Health to start importing workouts.',
      );
    }

    return const DeviceConnectionInfo(
      provider: FitnessProviderType.mock,
      available: true,
      connected: true,
      permissionStatus: 'preview',
      isPreviewMode: true,
      message: 'Preview data mode.',
    );
  }
}
