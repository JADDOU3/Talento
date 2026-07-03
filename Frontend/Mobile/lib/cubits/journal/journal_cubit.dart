import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/journal/journal_models.dart';
import '../../services/journal/journal_service.dart';
import 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  final JournalService _journalService;

  JournalCubit(this._journalService) : super(const JournalInitial());

  Future<void> loadJournal(int childId) async {
    emit(const JournalLoading());

    try {
      final results = await Future.wait<dynamic>([
        _journalService.getLatestReport(childId),
        _journalService.getWeeklySessions(),
        _journalService.getPerformances(childId),
      ]);

      final report = results[0] as AIReportModel?;
      final weeklySessions = results[1] as List<DailySessionModel>;
      final performances = results[2] as List<PerformanceModel>;

      if (report == null) {
        emit(
          JournalNoReport(
            weeklySessions: weeklySessions,
            performances: performances,
          ),
        );
        return;
      }

      emit(
        JournalLoaded(
          report: report,
          mindsetScores: report.mindsetScores,
          weeklySessions: weeklySessions,
          performances: performances,
          childId: childId,
        ),
      );
    } catch (e) {
      emit(JournalError(_cleanError(e)));
    }
  }

  Future<void> loadReportByVersion(int childId, String version) async {
    final currentState = state;

    final weeklySessions = _currentWeeklySessions(currentState);
    final performances = _currentPerformances(currentState);

    try {
      final report = await _journalService.getReportByVersion(
        childId,
        version,
      );

      if (report == null) {
        emit(
          JournalNoReport(
            weeklySessions: weeklySessions,
            performances: performances,
          ),
        );
        return;
      }

      emit(
        JournalLoaded(
          report: report,
          mindsetScores: report.mindsetScores,
          weeklySessions: weeklySessions,
          performances: performances,
          childId: childId,
        ),
      );
    } catch (e) {
      emit(JournalError(_cleanError(e)));
    }
  }

  List<DailySessionModel> _currentWeeklySessions(JournalState state) {
    if (state is JournalLoaded) return state.weeklySessions;
    if (state is JournalNoReport) return state.weeklySessions;
    return [];
  }

  List<PerformanceModel> _currentPerformances(JournalState state) {
    if (state is JournalLoaded) return state.performances;
    if (state is JournalNoReport) return state.performances;
    return [];
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}