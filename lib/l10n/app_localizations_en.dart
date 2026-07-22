// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GymApp';

  @override
  String get homeTitle => 'Home';

  @override
  String get workoutHistoryTitle => 'Workout History';

  @override
  String get progressTitle => 'Progress';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get workoutDetailTitle => 'Workout Detail';

  @override
  String get workoutNotFound => 'Workout not found.';

  @override
  String failedToLoadWorkout(String error) {
    return 'Failed to load workout: $error';
  }

  @override
  String get noWorkoutsFound => 'No workouts match your current filters.';

  @override
  String errorLoadingHistory(String error) {
    return 'Error loading history: $error';
  }

  @override
  String get activityHint => 'Activity';

  @override
  String get allActivities => 'All activities';

  @override
  String get sourceHint => 'Source';

  @override
  String get allSources => 'All sources';

  @override
  String get localAthlete => 'Local athlete';

  @override
  String failedToLoadSettings(String error) {
    return 'Failed to load settings: $error';
  }

  @override
  String get localDataTitle => 'Local data';

  @override
  String get localDataDescription =>
      'GymApp stores workouts, sync state, and your mock profile locally for the MVP.';

  @override
  String get clearLocalData => 'Clear local data';

  @override
  String get localDataCleared => 'Local data cleared.';

  @override
  String failedToLoadProgress(String error) {
    return 'Failed to load progress: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get retrySync => 'Retry sync';

  @override
  String get startupError => 'GymApp could not finish startup.';
}
