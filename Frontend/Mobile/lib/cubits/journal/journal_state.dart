import '../../models/journal/journal_models.dart';

abstract class JournalState {
  const JournalState();
}

class JournalInitial extends JournalState {
  const JournalInitial();
}

class JournalLoading extends JournalState {
  const JournalLoading();
}

class JournalError extends JournalState {
  final String message;

  const JournalError(this.message);
}

class JournalNoReport extends JournalState {
  final List<DailySessionModel> weeklySessions;
  final List<PerformanceModel> performances;

  const JournalNoReport({
    required this.weeklySessions,
    required this.performances,
  });
}

class JournalLoaded extends JournalState {
  final AIReportModel report;
  final List<MindsetScoreModel> mindsetScores;
  final List<DailySessionModel> weeklySessions;
  final List<PerformanceModel> performances;
  final int childId;

  const JournalLoaded({
    required this.report,
    required this.mindsetScores,
    required this.weeklySessions,
    required this.performances,
    required this.childId,
  });
}