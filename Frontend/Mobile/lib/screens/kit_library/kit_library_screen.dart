import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/widgets/app_background.dart';
import 'widgets/category_chip.dart';
import 'widgets/library_kit_card.dart';
import 'kit_details_screen.dart';

class KitLibraryScreen extends StatefulWidget {
  const KitLibraryScreen({super.key});

  @override
  State<KitLibraryScreen> createState() => _KitLibraryScreenState();
}

class _KitLibraryScreenState extends State<KitLibraryScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';

  final List<String> categories = ['All', 'STEM', 'Nature', 'Arts'];

  final List<Map<String, String>> kits = [
    {
      'title': 'Ocean Explorers',
      'description':
      'Dive into marine biology through interactive water experiments and sea life identification.',
      'category': 'STEM',
      'image':
      'https://images.unsplash.com/photo-1583212292454-1fe6229603b7?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Little Architect',
      'description':
      'Master the basics of structural engineering using modular blocks and physics puzzles.',
      'category': 'STEM',
      'image':
      'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Color Chemists',
      'description':
      'Explore the science of pigments and light through creative painting techniques.',
      'category': 'Arts',
      'image':
      'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Garden Botanist',
      'description':
      'Understand plant lifecycles by growing your own ecosystem in a glass terrarium.',
      'category': 'Nature',
      'image':
      'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?auto=format&fit=crop&w=800&q=80',
    },
  ];

  List<Map<String, String>> get filteredKits {
    return kits.where((kit) {
      final matchesCategory =
          selectedCategory == 'All' || kit['category'] == selectedCategory;

      final matchesSearch =
          kit['title']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
              kit['description']!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            const TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'مكتبة الحزم',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ابحث عن تجربة',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.yellow,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 16),
                    _buildSearchAndFilterRow(),
                    const SizedBox(height: 14),
                    _buildCategoryChips(),
                    const SizedBox(height: 16),
                    _buildKitsList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 1,
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.tune_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            textAlign: TextAlign.right,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن تجربة',
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.yellow,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryChip(
            label: category,
            isSelected: selectedCategory == category,
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildKitsList() {
    final items = filteredKits;

    return Column(
      children: items.map((kit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: LibraryKitCard(
            title: kit['title']!,
            description: kit['description']!,
            category: kit['category']!,
            imageUrl: kit['image']!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const KitDetailsScreen(),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}