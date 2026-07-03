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
import '../../shared/layout/app_drawer.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/layout/top_bar.dart';

import 'widgets/journal_card.dart';
import 'widgets/skill_progress_item.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  static const String _latestOptionValue = '__latest__';

  late final JournalCubit _journalCubit;

  String? _latestVersion;
  String _selectedVersion = _latestOptionValue;

  @override
  void initState() {
    super.initState();
    _journalCubit = JournalCubit(JournalService())..loadSelectedChildJournal();
  }

  @override
  void dispose() {
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

                      return BlocConsumer<JournalCubit, JournalState>(
                        listener: (context, state) {
                          if (state is JournalLoaded) {
                            final version = state.report.analysisVersion.trim();

                            if (_latestVersion == null &&
                                version.isNotEmpty) {
                              setState(() {
                                _latestVersion = version;
                                _selectedVersion = _latestOptionValue;
                              });
                            }
                          }
                        },
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
                                  _buildAchievementCard(state.report),
                                  const SizedBox(height: 18),

                                  if (state.mindsetScores.isNotEmpty) ...[
                                    _buildMindsetScoresCard(
                                      state.mindsetScores,
                                    ),
                                    const SizedBox(height: 18),
                                  ],

                                  _buildAhaCard(state.report),
                                  const SizedBox(height: 18),
                                ],

                                if (state is JournalNoReport) ...[
                                  _buildNoReportBanner(),
                                  const SizedBox(height: 18),
                                ],

                                _buildWeeklyInsights(weeklySessions),

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اليوميات',
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (loadedState != null) ...[
          const SizedBox(height: 10),
          _buildVersionDropdown(context, loadedState),
        ],
      ],
    );
  }

  Widget _buildVersionDropdown(
      BuildContext context,
      JournalLoaded state,
      ) {
    final latestVersion =
        _latestVersion ?? state.report.analysisVersion.trim();
    final versions = _versionsUpTo(latestVersion);
    final selectedLabel = _selectedVersion == _latestOptionValue
        ? 'الأسبوع الحالي'
        : _selectedVersion;

    return PopupMenuButton<String>(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.yellow.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.yellow.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.yellow,
              size: 22,
            ),
            const SizedBox(width: 6),
            Text(
              selectedLabel,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(AIReportModel report) {
    final value = _normalizeScore(report.analysisConfidence);
    final percent = (value * 100).round();
    final trend = _trendInfo(report.focusTrend);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.secondary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.track_changes_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(
                  '$percent%',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'معدل الإنجاز العام',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: trend.color.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    trend.label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMindsetScoresCard(List<MindsetScoreModel> scores) {
    final colors = [
      AppColors.primary,
      AppColors.pink,
      AppColors.secondary,
      AppColors.yellow,
    ];

    return JournalCard(
      color: const Color(0xFFFFF3F6),
      borderColor: AppColors.pink.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('بطاقة أداء المهارات'),
          const SizedBox(height: 4),
          Text(
            'بناء على أدائك الأسبوعي',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 18),
          ...scores.asMap().entries.map(
                (entry) {
              final index = entry.key;
              final score = entry.value;

              return SkillProgressItem(
                name: _mindsetArabicName(score.mindsetName),
                value: _normalizeScore(score.score),
                color: colors[index % colors.length],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAhaCard(AIReportModel report) {
    final items = [
      _AhaMomentText(
        icon: Icons.push_pin_rounded,
        color: AppColors.primary,
        text: report.summary,
      ),
      _AhaMomentText(
        icon: Icons.psychology_alt_rounded,
        color: AppColors.pink,
        text: report.learningBehaviorPattern,
      ),
      _AhaMomentText(
        icon: Icons.visibility_rounded,
        color: AppColors.secondary,
        text: report.recommendedFutureObservation,
      ),
    ].where((item) => item.text.trim().isNotEmpty).toList();

    return JournalCard(
      color: AppColors.cardBackground,
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBubble(Icons.auto_awesome_rounded, AppColors.pink),
              const SizedBox(width: 10),
              _sectionTitle('لحظات "Aha!" ✨'),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Text(
              'سيتم عرض لحظات التعلّم هنا قريباً',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            )
          else
            ...items.asMap().entries.map(
                  (entry) {
                final index = entry.key;
                final item = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == items.length - 1 ? 0 : 12,
                  ),
                  child: _buildAhaTextItem(
                    icon: item.icon,
                    color: item.color,
                    text: item.text,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAhaTextItem({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 15,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoReportBanner() {
    return JournalCard(
      color: const Color(0xFFEFFFFB),
      borderColor: AppColors.primary.withValues(alpha: 0.10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🌱',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد تقرير متاح بعد',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'العب بعض الأنشطة وسنقوم بإنشاء تقريرك قريباً',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyInsights(List<DailySessionModel> sessions) {
    final days = _buildWeeklyChartDays(sessions);
    final allEmpty = days.every((day) => day.count == 0);
    final maxCount = days
        .map((day) => day.count)
        .fold<int>(0, (previous, current) {
      return current > previous ? current : previous;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('استكشافاتك الأسبوعية'),
        const SizedBox(height: 10),
        JournalCard(
          color: const Color(0xFFEFFFFB),
          borderColor: AppColors.primary.withValues(alpha: 0.08),
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 150,
            child: allEmpty
                ? Align(
              alignment: Alignment.topRight,
              child: Text(
                'سيتم عرض استكشافاتك الأسبوعية هنا قريباً',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.hint,
                ),
              ),
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days
                  .map(
                    (day) => Expanded(
                  child: _buildWeeklyBar(
                    label: day.label,
                    count: day.count,
                    maxCount: maxCount,
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyBar({
    required String label,
    required int count,
    required int maxCount,
  }) {
    final fillPercent = maxCount == 0 ? 0.0 : count / maxCount;
    final barHeight = 86.0 * fillPercent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$count',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 90,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 18,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    width: 18,
                    height: count == 0 ? 0 : barHeight.clamp(8.0, 86.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCards(List<PerformanceModel> performances) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('أداء الأنشطة'),
        const SizedBox(height: 10),
        ...performances.asMap().entries.map(
              (entry) {
            final index = entry.key;
            final performance = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == performances.length - 1 ? 0 : 12,
              ),
              child: _buildPerformanceActivityCard(performance),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPerformanceActivityCard(PerformanceModel performance) {
    final items = [
      _PerformanceMetric(
        label: 'نسبة الإتمام',
        value: performance.completionScore,
        color: AppColors.primary,
      ),
      _PerformanceMetric(
        label: 'المثابرة',
        value: performance.persistenceScore,
        color: AppColors.pink,
      ),
      _PerformanceMetric(
        label: 'الكفاءة',
        value: performance.efficiencyScore,
        color: AppColors.secondary,
      ),
      _PerformanceMetric(
        label: 'الاستقلالية',
        value: performance.independenceScore,
        color: AppColors.yellow,
      ),
      _PerformanceMetric(
        label: 'الاستراتيجية',
        value: performance.strategyScore,
        color: AppColors.primary,
      ),
    ];

    return JournalCard(
      color: AppColors.cardBackground,
      borderColor: AppColors.border,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نشاط رقم ${performance.activityId}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
                (item) => SkillProgressItem(
              name: item.label,
              value: _normalizeScore(item.value),
              color: item.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyLarge.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _iconBubble(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.13),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 23),
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

double _normalizeScore(double score) {
  if (score.isNaN || score.isInfinite) return 0;

  if (score > 1) {
    return (score / 100).clamp(0.0, 1.0).toDouble();
  }

  return score.clamp(0.0, 1.0).toDouble();
}

String _mindsetArabicName(String name) {
  const mindsetNameAr = {
    'Cognitive': 'المعرفي',
    'Social-Emotional': 'الاجتماعي العاطفي',
    'Sensory-Kinesthetic': 'الحسي الحركي',
    'Creative-Visual': 'الإبداعي البصري',
  };

  return mindsetNameAr[name.trim()] ?? name;
}

_TrendInfo _trendInfo(String trend) {
  switch (trend.trim().toLowerCase()) {
    case 'improving':
      return const _TrendInfo('تحسن', AppColors.primary);
    case 'declining':
      return const _TrendInfo('تراجع', Colors.redAccent);
    case 'stable':
      return const _TrendInfo('مستقر', AppColors.hint);
    default:
      return const _TrendInfo('مستقر', AppColors.hint);
  }
}

List<String> _versionsUpTo(String version) {
  final trimmed = version.trim();

  if (trimmed.isEmpty) return [];

  final number = int.tryParse(trimmed.replaceAll(RegExp(r'[^0-9]'), ''));

  if (number == null || number <= 0) {
    return [trimmed];
  }

  return List.generate(number, (index) => 'v${index + 1}');
}

List<_WeeklyChartDay> _buildWeeklyChartDays(
    List<DailySessionModel> sessions,
    ) {
  const fallbackDays = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  if (sessions.isEmpty) {
    return fallbackDays
        .map((label) => _WeeklyChartDay(label: label, count: 0))
        .toList();
  }

  final sortedSessions = [...sessions]
    ..sort((a, b) => a.date.compareTo(b.date));

  final lastSeven = sortedSessions.length > 7
      ? sortedSessions.sublist(sortedSessions.length - 7)
      : sortedSessions;

  final chartDays = <_WeeklyChartDay>[];

  for (var i = 0; i < lastSeven.length; i++) {
    final session = lastSeven[i];
    final label = _arabicWeekdayFromDate(session.date);

    chartDays.add(
      _WeeklyChartDay(
        label: label.isEmpty ? fallbackDays[i % fallbackDays.length] : label,
        count: session.count,
      ),
    );
  }

  while (chartDays.length < 7) {
    chartDays.insert(
      0,
      _WeeklyChartDay(
        label: fallbackDays[chartDays.length % fallbackDays.length],
        count: 0,
      ),
    );
  }

  return chartDays;
}

String _arabicWeekdayFromDate(String date) {
  const weekdayAr = {
    1: 'الأحد',
    2: 'الاثنين',
    3: 'الثلاثاء',
    4: 'الأربعاء',
    5: 'الخميس',
    6: 'الجمعة',
    7: 'السبت',
  };

  final parsed = DateTime.tryParse(date);

  if (parsed == null) return '';

  final talentoWeekday =
  parsed.weekday == DateTime.sunday ? 1 : parsed.weekday + 1;

  return weekdayAr[talentoWeekday] ?? '';
}

class _TrendInfo {
  final String label;
  final Color color;

  const _TrendInfo(this.label, this.color);
}

class _AhaMomentText {
  final IconData icon;
  final Color color;
  final String text;

  const _AhaMomentText({
    required this.icon,
    required this.color,
    required this.text,
  });
}

class _PerformanceMetric {
  final String label;
  final double value;
  final Color color;

  const _PerformanceMetric({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _WeeklyChartDay {
  final String label;
  final int count;

  const _WeeklyChartDay({
    required this.label,
    required this.count,
  });
}