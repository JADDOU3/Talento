// ============================================================
// lib/screens/home/new_user.dart
// ============================================================
import 'package:flutter/material.dart';

import '../../shared/layout/app_drawer.dart';
import '../../models/kit/kit_model.dart';
import '../../services/kit/kit_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/layout/top_bar.dart';
import '../journal/journal_screen.dart';
import '../kit_library/kit_details_screen.dart';
import '../kit_library/kit_library_screen.dart';
import '../profile/profile_screen.dart';
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
  final KitService _kitService = KitService();

  late Future<List<KitModel>> _kitsFuture;

  @override
  void initState() {
    super.initState();
    _kitsFuture = _loadFirstKits();
  }

  Future<List<KitModel>> _loadFirstKits() async {
    final kits = await _kitService.getAllKits();
    return kits.take(3).toList();
  }

  Future<void> _refreshKits() async {
    setState(() {
      _kitsFuture = _loadFirstKits();
    });
  }

  void _goToKitsList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const KitLibraryScreen(),
      ),
    );
  }

  void _goToKitDetails(int kitId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KitDetailsScreen(kitId: kitId),
      ),
    );
  }

  void _goToJournal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const JournalScreen(),
      ),
    );
  }

  void _goToAddChildFlow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(
          openAddChildDialog: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: AppBackground(
        child: Column(
          children: [
            const TopBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshKits,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const BannerCard(),
                      const SizedBox(height: 20),
                      StartNowCard(
                        onTap: _goToAddChildFlow,
                      ),
                      const SizedBox(height: 24),
                      _buildKitSection(),
                      const SizedBox(height: 24),
                      PromotionCard(
                        onTap: _goToJournal,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
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
              onPressed: _goToKitsList,
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
          'مغامرات مصممة لتنمية طفلك',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6B728F),
          ),
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<KitModel>>(
          future: _kitsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildKitsLoading();
            }

            if (snapshot.hasError) {
              return _buildKitsError();
            }

            final kits = snapshot.data ?? [];

            if (kits.isEmpty) {
              return _buildEmptyKits();
            }

            return SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kits.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final kit = kits[i];

                  return KitCard(
                    title: kit.name,
                    description: kit.description,
                    duration: 'حزمة تعليمية',
                    age: kit.age == 0 ? '4-7' : '${kit.age}+',
                    image: kit.imageUrl,
                    onTap: () => _goToKitDetails(kit.id),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildKitsLoading() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) {
          return Container(
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE3E8EE)),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF10A896),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKitsError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E8EE)),
      ),
      child: Column(
        children: [
          const Text(
            'صار خطأ أثناء تحميل الحزم',
            style: TextStyle(
              color: Color(0xFF1B1F24),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _refreshKits,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyKits() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E8EE)),
      ),
      child: const Text(
        'لا توجد حزم متاحة حاليًا',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF6B728F),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}