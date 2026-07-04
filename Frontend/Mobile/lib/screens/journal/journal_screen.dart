import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';
import '../../cubits/child_mode/child_mode_state.dart';
import '../../cubits/journal/journal_cubit.dart';
import '../../cubits/journal/journal_state.dart';
import '../../models/journal/journal_models.dart';
import '../../services/journal/journal_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/app_drawer.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/layout/top_bar.dart';

import 'widgets/journal_report_cards.dart';
import 'widgets/journal_ui_helpers.dart';
import 'widgets/performance_activity_card.dart';
import 'widgets/weekly_sessions_card.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  static const String _latestOptionValue = '__latest__';

  late final JournalCubit _journalCubit;
  late final PageController _performancePageController;

  String? _latestVersion;
  String _selectedVersion = _latestOptionValue;

  @override
  void initState() {
    super.initState();
    _journalCubit = JournalCubit(JournalService())..loadSelectedChildJournal();
    _performancePageController = PageController(
      viewportFraction: 0.90,
    );
  }

  @override
  void dispose() {
    _performancePageController.dispose();
    _journalCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _journalCubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          drawer: const AppDrawer(),
          body: AppBackground(
            child: Column(
              children: [
                const TopBar(),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final childModeState =
                          context.watch<ChildModeCubit>().state;
                      final isChildMode = childModeState is ChildModeStatus &&
                          childModeState.isChildMode;

                      if (isChildMode) {
                        return _buildChildModeBlocked();
                      }

                      return BlocConsumer<JournalCubit, JournalState>(
                        listener: _onJournalStateChanged,
                        builder: (context, state) {
                          if (state is JournalInitial ||
                              state is JournalLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }

                          if (state is JournalError) {
                            return _buildErrorState(context, state.message);
                          }

                          final loadedState =
                          state is JournalLoaded ? state : null;
                          final weeklySessions =
                          _weeklySessionsFromState(state);
                          final performances = _performancesFromState(state);

                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeader(
                                  context,
                                  loadedState: loadedState,
                                ),
                                const SizedBox(height: 18),
                                if (state is JournalLoaded) ...[
                                  if (state.mindsetScores.isNotEmpty) ...[
                                    MindsetScoresCard(
                                      scores: state.mindsetScores,
                                    ),
                                    const SizedBox(height: 18),
                                  ],
                                  AhaMomentsCard(report: state.report),
                                  const SizedBox(height: 18),
                                ],
                                if (state is JournalNoReport) ...[
                                  const NoReportBanner(),
                                  const SizedBox(height: 18),
                                ],
                                WeeklySessionsCard(
                                  sessions: weeklySessions,
                                ),
                                if (performances.isNotEmpty) ...[
                                  const SizedBox(height: 18),
                                  _buildPerformanceCards(performances),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const BottomNavBar(selectedIndex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onJournalStateChanged(BuildContext context, JournalState state) {
    if (state is JournalLoaded) {
      final version = state.report.analysisVersion.trim();

      if (_latestVersion == null && version.isNotEmpty) {
        setState(() {
          _latestVersion = version;
          _selectedVersion = _latestOptionValue;
        });
      }
    }
  }

  Widget _buildChildModeBlocked() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_rounded,
            size: 64,
            color: AppColors.hint.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'هذه الصفحة غير متاحة في وضع الطفل',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 50,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _latestVersion = null;
                  _selectedVersion = _latestOptionValue;
                });

                context.read<JournalCubit>().loadSelectedChildJournal();
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, {
        required JournalLoaded? loadedState,
      }) {
    if (loadedState == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: _headerDecoration(),
        child: Align(
          alignment: Alignment.centerRight,
          child: _buildJournalTitle(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
      decoration: _headerDecoration(),
      child: Row(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AchievementRateCard(report: loadedState.report),
          const SizedBox(width: 16),
          Container(
            width: 1.2,
            height: 112,
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildJournalTitle(),
                const SizedBox(height: 7),
                Text(
                  'تحليل شامل لتقدم طفلك هذا الأسبوع',
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                _buildVersionDropdown(context, loadedState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _headerDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.white.withValues(alpha: 0.92),
          AppColors.white.withValues(alpha: 0.72),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      borderRadius: BorderRadius.circular(32),
      border: Border.all(
        color: AppColors.white.withValues(alpha: 0.95),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.07),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: AppColors.white.withValues(alpha: 0.70),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }

  Widget _buildJournalTitle() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 40),
          Text(
            'اليوميات',
            textAlign: TextAlign.right,
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionDropdown(
      BuildContext context,
      JournalLoaded state,
      ) {
    final latestVersion =
        _latestVersion ?? state.report.analysisVersion.trim();
    final versions = versionsUpTo(latestVersion);
    final selectedLabel = _selectedVersion == _latestOptionValue
        ? 'الأسبوع الحالي'
        : _selectedVersion;

    return Align(
      alignment: Alignment.centerRight,
      child: PopupMenuButton<String>(
        initialValue: _selectedVersion,
        onSelected: (value) {
          if (value == _selectedVersion) return;

          setState(() {
            _selectedVersion = value;
          });

          if (value == _latestOptionValue) {
            context.read<JournalCubit>().loadJournal(state.childId);
            return;
          }

          context.read<JournalCubit>().loadReportByVersion(
            state.childId,
            value,
          );
        },
        itemBuilder: (context) {
          return [
            const PopupMenuItem<String>(
              value: _latestOptionValue,
              child: Text('الأسبوع الحالي'),
            ),
            if (versions.isNotEmpty) const PopupMenuDivider(),
            ...versions.map(
                  (version) => PopupMenuItem<String>(
                value: version,
                child: Text(version),
              ),
            ),
          ];
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.yellow.withValues(alpha: 0.20),
                AppColors.yellow.withValues(alpha: 0.08),
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.yellow.withValues(alpha: 0.36),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.yellow.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.yellow.withValues(alpha: 0.95),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.yellow,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceCards(List<PerformanceModel> performances) {
    final sortedPerformances = [...performances]
      ..sort((a, b) => a.activityId.compareTo(b.activityId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Text(
                'أداء الأنشطة',
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${sortedPerformances.length} نشاط',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 305,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: PageView.builder(
              controller: _performancePageController,
              itemCount: sortedPerformances.length,
              padEnds: false,
              itemBuilder: (context, index) {
                final performance = sortedPerformances[index];

                return Padding(
                  padding: EdgeInsets.only(
                    left: index == sortedPerformances.length - 1 ? 0 : 10,
                  ),
                  child: PerformanceActivityCard(
                    performance: performance,
                  ),
                );
              },
            ),
          ),
        ),
        if (sortedPerformances.length > 1) ...[
          const SizedBox(height: 8),
          Text(
            'اسحب لعرض باقي الأنشطة',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.hint,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

List<DailySessionModel> _weeklySessionsFromState(JournalState state) {
  if (state is JournalLoaded) return state.weeklySessions;
  if (state is JournalNoReport) return state.weeklySessions;
  return [];
}

List<PerformanceModel> _performancesFromState(JournalState state) {
  if (state is JournalLoaded) return state.performances;
  if (state is JournalNoReport) return state.performances;
  return [];
}