import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/journal/journal_models.dart';
import '../../services/journal/journal_service.dart';
import 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  final JournalService _journalService;

  JournalCubit(this._journalService) : super(const JournalInitial());

  Future<void> loadSelectedChildJournal() async {
    emit(const JournalLoading());

    try {
      final childId = await _journalService.getSelectedChildId();

      if (childId == null) {
        emit(const JournalError('لا يوجد طفل مختار حالياً'));
        return;
      }

      await _loadJournalData(childId);
    } catch (e) {
      emit(JournalError(_cleanError(e)));
    }
  }

  Future<void> loadJournal(int childId) async {
    emit(const JournalLoading());

    await _loadJournalData(childId);
  }

  Future<void> _loadJournalData(int childId) async {
    final report = await _safeLoad<AIReportModel?>(
      label: 'latest report',
      fallback: null,
      loader: () => _journalService.getLatestReport(childId),
    );

    final weeklySessions = await _safeLoad<List<DailySessionModel>>(
      label: 'weekly sessions',
      fallback: <DailySessionModel>[],
      loader: _journalService.getWeeklySessions,
    );

    final performances = await _safeLoad<List<PerformanceModel>>(
      label: 'performances',
      fallback: <PerformanceModel>[],
      loader: () => _journalService.getPerformances(childId),
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
  }

  Future<void> loadReportByVersion(int childId, String version) async {
    final currentState = state;

    final weeklySessions = _currentWeeklySessions(currentState);
    final performances = _currentPerformances(currentState);

    final report = await _safeLoad<AIReportModel?>(
      label: 'report version $version',
      fallback: null,
      loader: () => _journalService.getReportByVersion(childId, version),
    );

    if (report == null) {
      if (currentState is JournalLoaded) {
        emit(currentState);
        return;
      }

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
  }

  Future<T> _safeLoad<T>({
    required String label,
    required T fallback,
    required Future<T> Function() loader,
  }) async {
    try {
      return await loader();
    } catch (e) {
      // مهم للتشخيص: هيك بنعرف أي endpoint ضرب من الـ debug console
      // ignore: avoid_print
      print('Journal $label failed: ${_cleanError(e)}');
      return fallback;
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