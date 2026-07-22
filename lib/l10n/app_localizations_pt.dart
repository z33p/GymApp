// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'GymApp';

  @override
  String get homeTitle => 'Início';

  @override
  String get workoutHistoryTitle => 'Histórico de Treinos';

  @override
  String get progressTitle => 'Progresso';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get workoutDetailTitle => 'Detalhes do Treino';

  @override
  String get workoutNotFound => 'Treino não encontrado.';

  @override
  String failedToLoadWorkout(String error) {
    return 'Falha ao carregar treino: $error';
  }

  @override
  String get noWorkoutsFound =>
      'Nenhum treino encontrado com os filtros atuais.';

  @override
  String errorLoadingHistory(String error) {
    return 'Erro ao carregar histórico: $error';
  }

  @override
  String get activityHint => 'Atividade';

  @override
  String get allActivities => 'Todas as atividades';

  @override
  String get sourceHint => 'Origem';

  @override
  String get allSources => 'Todas as origens';

  @override
  String get localAthlete => 'Atleta local';

  @override
  String failedToLoadSettings(String error) {
    return 'Falha ao carregar configurações: $error';
  }

  @override
  String get localDataTitle => 'Dados locais';

  @override
  String get localDataDescription =>
      'O GymApp armazena treinos, estado de sincronização e seu perfil de teste localmente para o MVP.';

  @override
  String get clearLocalData => 'Limpar dados locais';

  @override
  String get localDataCleared => 'Dados locais limpos.';

  @override
  String failedToLoadProgress(String error) {
    return 'Falha ao carregar progresso: $error';
  }

  @override
  String get retry => 'Tentar novamente';

  @override
  String get dismiss => 'Descartar';

  @override
  String get retrySync => 'Tentar sincronização novamente';

  @override
  String get startupError => 'O GymApp não conseguiu concluir a inicialização.';
}
