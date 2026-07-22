// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'GymApp';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get workoutHistoryTitle => 'Historial de Entrenamientos';

  @override
  String get progressTitle => 'Progreso';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get workoutDetailTitle => 'Detalle del Entrenamiento';

  @override
  String get workoutNotFound => 'Entrenamiento no encontrado.';

  @override
  String failedToLoadWorkout(String error) {
    return 'Error al cargar entrenamiento: $error';
  }

  @override
  String get noWorkoutsFound =>
      'Ningún entrenamiento coincide con los filtros actuales.';

  @override
  String errorLoadingHistory(String error) {
    return 'Error al cargar historial: $error';
  }

  @override
  String get activityHint => 'Actividad';

  @override
  String get allActivities => 'Todas las actividades';

  @override
  String get sourceHint => 'Fuente';

  @override
  String get allSources => 'Todas las fuentes';

  @override
  String get localAthlete => 'Atleta local';

  @override
  String failedToLoadSettings(String error) {
    return 'Error al cargar ajustes: $error';
  }

  @override
  String get localDataTitle => 'Datos locales';

  @override
  String get localDataDescription =>
      'GymApp almacena entrenamientos, estado de sincronización y tu perfil localmente para el MVP.';

  @override
  String get clearLocalData => 'Borrar datos locales';

  @override
  String get localDataCleared => 'Datos locales borrados.';

  @override
  String failedToLoadProgress(String error) {
    return 'Error al cargar progreso: $error';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get dismiss => 'Descartar';

  @override
  String get retrySync => 'Reintentar sincronización';

  @override
  String get startupError => 'GymApp no pudo finalizar el inicio.';
}
