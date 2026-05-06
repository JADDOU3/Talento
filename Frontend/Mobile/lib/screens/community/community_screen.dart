import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/widgets/app_background.dart';
import 'widgets/action_icon_button.dart';
import 'widgets/category_chip.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/feature_card.dart';
import 'widgets/post_card.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int selectedChip = 0;

  final List<String> categories = const [
    'كل التخصصات',
    'مجموعة الروبوتات',
    'التعلّم',
    'الفنون',
  ];

  final List<Map<String, dynamic>> feedData = const [
    {
      'id': 1,
      'user': 'إلينا وسام',
      'time': 'منذ ساعتين',
      'avatar':
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
      'image':
      'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=900',
      'caption':
      'أخيراً مررنا بلحظة الاكتشاف! تجربة ممتعة مع الأصدقاء في مهمة الفضاء 🚀',
      'likes': 12,
    },
    {
      'id': 2,
      'user': 'ديفيد تشن',
      'time': 'منذ 5 ساعات',
      'avatar':
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      'image':
      'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=900',
      'caption':
      'مشاركة مابيا في مجموعة التعبيرات الفنية كانت مليئة بالألوان والإبداع 🎨',
      'likes': 8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: Column(
            children: [
              const TopBar(),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FeatureCard(),

                      Transform.translate(
                        offset: const Offset(0, -28),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SearchBar(),

                              const SizedBox(height: 10),

                              SizedBox(
                                height: 38,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: categories.length,
                                  separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    return CategoryChip(
                                      label: categories[index],
                                      isSelected: selectedChip == index,
                                      onTap: () {
                                        setState(() => selectedChip = index);
                                      },
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 24),

                              Center(
                                child: ActionIconButton(
                                  text: 'شارك قصتك',
                                  onTap: () {},
                                ),
                              ),

                              const SizedBox(height: 28),

                              Text(
                                'القصص الحديثة',
                                textAlign: TextAlign.right,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              const SizedBox(height: 14),

                              ...feedData.map(
                                    (post) => Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: PostCard(
                                    user: post['user'],
                                    time: post['time'],
                                    avatarUrl: post['avatar'],
                                    imageUrl: post['image'],
                                    caption: post['caption'],
                                    likes: post['likes'],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const CustomBottomNav(selectedIndex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: 'ابحث في القصص، المشاريع، أو الأشخاص...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.hint,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.hint,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}