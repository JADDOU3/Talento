import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/activities/story_spinner/story_submission_model.dart';
import '../../services/activities/story_submission_repository.dart';
import '../../shared/layout/app_background.dart';

class StorySpinnerStoriesScreen extends StatefulWidget {
  final int activityId;
  final int childId;

  const StorySpinnerStoriesScreen({
    super.key,
    required this.activityId,
    required this.childId,
  });

  @override
  State<StorySpinnerStoriesScreen> createState() =>
      _StorySpinnerStoriesScreenState();
}

class _StorySpinnerStoriesScreenState extends State<StorySpinnerStoriesScreen> {
  final StorySubmissionRepository _repository = StorySubmissionRepository();

  late Future<List<StorySubmission>> _storiesFuture;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  void _loadStories() {
    _storiesFuture = _repository.getStoriesByActivityAndChild(
      widget.activityId,
      widget.childId,
    );
  }

  Future<void> _refreshStories() async {
    setState(() {
      _loadStories();
    });

    await _storiesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: FutureBuilder<List<StorySubmission>>(
              future: _storiesFuture,
              builder: (context, snapshot) {
                final stories = snapshot.data ?? [];

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refreshStories,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                    children: [
                      const _TopHeader(),
                      const SizedBox(height: 20),
                      _PageTitle(
                        count: stories.length,
                        isLoading:
                        snapshot.connectionState == ConnectionState.waiting,
                      ),
                      const SizedBox(height: 24),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const _LoadingCard()
                      else if (snapshot.hasError)
                        _ErrorCard(
                          onRetry: () {
                            setState(() {
                              _loadStories();
                            });
                          },
                        )
                      else if (stories.isEmpty)
                          const _EmptyStoriesCard()
                        else
                          ...stories.asMap().entries.map(
                                (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _StoryCard(
                                story: entry.value,
                                index: entry.key,
                              ),
                            ),
                          ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.white.withOpacity(0.92),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 13,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _TopCircleButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.arrow_back_ios_new_rounded,
          ),
          const Spacer(),
          Image.asset(
            'assets/icons/logo1.png',
            height: 42,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Text(
                'Talento',
                style: TextStyle(
                  fontFamily: 'BerlinSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const _TopCircleButton({
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  final int count;
  final bool isLoading;

  const _PageTitle({
    required this.count,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = isLoading
        ? 'جاري تحميل القصص التي أنهيتها...'
        : count == 0
        ? 'هنا ستظهر القصص الصحيحة بعد إنهاء النشاط'
        : 'عندك $count قصة مكتملة ومحفوظة';

    return Column(
      children: [
        Text(
          'قصصي',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(
            fontFamily: 'DGAgnadeen',
            color: AppColors.textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13.2,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}

class _EmptyStoriesCard extends StatelessWidget {
  const _EmptyStoriesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.white.withOpacity(0.86),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.yellow.withOpacity(0.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.yellow,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لسا ما في قصص محفوظة',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ قصة جديدة، ولما تستخدم العناصر الثلاثة بشكل صحيح رح تنحفظ هون.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13.2,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.error.withOpacity(0.16),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.error,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            'ما قدرنا نحمّل القصص',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'تأكدي من الاتصال وحاولي مرة ثانية.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 19),
              label: Text(
                'إعادة المحاولة',
                style: AppTextStyles.button.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final StorySubmission story;
  final int index;

  const _StoryCard({
    required this.story,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final createdAtText = _formatCreatedAt(story.createdAt);
    final keywords = story.keywords;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.93),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.white.withOpacity(0.88),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _storyColor(index).withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: _storyColor(index),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'قصة ${index + 1}',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (createdAtText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    createdAtText,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.045),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              story.storyText.trim().isEmpty
                  ? 'لا يوجد نص محفوظ لهذه القصة.'
                  : story.storyText.trim(),
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                height: 1.55,
              ),
            ),
          ),
          if (keywords.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: keywords.map((keyword) {
                return _KeywordChip(keyword: keyword);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _storyColor(int index) {
    final colors = <Color>[
      AppColors.primary,
      AppColors.pink,
      AppColors.secondary,
      AppColors.yellow,
    ];

    return colors[index % colors.length];
  }

  String _formatCreatedAt(Object? value) {
    if (value == null) return '';

    DateTime? date;

    if (value is DateTime) {
      date = value;
    } else {
      date = DateTime.tryParse(value.toString());
    }

    if (date == null) {
      final raw = value.toString().trim();
      if (raw.isEmpty) return '';
      return raw.replaceFirst('T', ' ').split('.').first;
    }

    final localDate = date.toLocal();

    return '${_two(localDate.hour)}:${_two(localDate.minute)}  '
        '${_two(localDate.day)}/${_two(localDate.month)}/${localDate.year}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class _KeywordChip extends StatelessWidget {
  final String keyword;

  const _KeywordChip({
    required this.keyword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.yellow.withOpacity(0.17),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.yellow.withOpacity(0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: AppColors.yellow,
          ),
          const SizedBox(width: 5),
          Text(
            keyword,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 12.2,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}