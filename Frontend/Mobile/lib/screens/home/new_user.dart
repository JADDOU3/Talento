// ============================================================
// lib/screens/home/new_user.dart
// ============================================================
import 'package:flutter/material.dart';

import '../../shared/layout/app_drawer.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/layout/top_bar.dart';
import 'widgets/banner_card.dart';
import 'widgets/kit_card.dart';
import 'widgets/promotion_card.dart';
import 'widgets/start_now_card.dart';

class NewUser extends StatefulWidget {
  const NewUser({super.key});

  @override
  State<NewUser> createState() => _NewUser();
}

class _NewUser extends State<NewUser> {
  final int _selectedIndex = 0;

  final List<Map<String, String>> kits = [
    {
      'title': 'KIT1',
      'description': 'اكتشف عالم النبات',
      'duration': '8 أسابيع',
      'age': '3-6',
      'image': 'assets/images/kit1.png',
    },
    {
      'title': 'KIT2',
      'description': 'تجارب علمية ممتعة',
      'duration': '12 أسبوع',
      'age': '4-7',
      'image': 'assets/images/kit2.png',
    },
    {
      'title': 'KIT3',
      'description': 'عالم الفن والإبداع',
      'duration': '6 أسابيع',
      'age': '3-5',
      'image': 'assets/images/kit3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: AppBackground(
        child: Column(
          children: [
            const TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const BannerCard(),
                    const SizedBox(height: 20),
                    const StartNowCard(),
                    const SizedBox(height: 24),
                    _buildKitSection(),
                    const SizedBox(height: 24),
                    const PromotionCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            BottomNavBar(
              selectedIndex: _selectedIndex,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'اكتشف المجموعات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B1F24),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'عرض الكل',
                style: TextStyle(
                  color: Color(0xFF10A896),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'مغامرات مصممة لتنمية طفلك ',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6B728F),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => KitCard(
              title: kits[i]['title']!,
              description: kits[i]['description']!,
              duration: kits[i]['duration']!,
              age: kits[i]['age']!,
              image: kits[i]['image']!,
            ),
          ),
        ),
      ],
    );
  }
}