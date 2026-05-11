import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/kit/kit_cubit.dart';
import '../../cubits/kit/kit_state.dart';
import '../../models/kit/kit_enums.dart';
import '../../services/kit/kit_service.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/widgets/app_background.dart';
import 'kit_details_screen.dart';
import 'widgets/category_chip.dart';
import 'widgets/library_kit_card.dart';

class KitLibraryScreen extends StatelessWidget {
  const KitLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KitCubit(KitService())..getAllKits(),
      child: const _KitLibraryView(),
    );
  }
}

class _KitLibraryView extends StatefulWidget {
  const _KitLibraryView();

  @override
  State<_KitLibraryView> createState() => _KitLibraryViewState();
}

class _KitLibraryViewState extends State<_KitLibraryView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String _selectedLabel = 'الكل';

  final List<_MindsetFilterOption> _mindsetFilters = const [
    _MindsetFilterOption(label: 'الكل'),
    _MindsetFilterOption(
      label: 'البنّاء',
      mindset: Mindset.builder,
    ),
    _MindsetFilterOption(
      label: 'العالِم',
      mindset: Mindset.scientist,
    ),
    _MindsetFilterOption(
      label: 'المستكشف',
      mindset: Mindset.explorer,
    ),
    _MindsetFilterOption(
      label: 'المخترع',
      mindset: Mindset.inventor,
    ),
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: Column(
            children: [
              const TopBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'مكتبة الحزم',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.primary,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),

                      const SizedBox(height: 4),
                      const SizedBox(height: 16),
                      _buildSearchField(context),
                      const SizedBox(height: 10),
                      _buildMindsetChips(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: BlocBuilder<KitCubit, KitState>(
                          builder: (context, state) {
                            if (state is KitLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state is KitError) {
                              return _buildMessageState(
                                icon: Icons.error_outline_rounded,
                                message: state.message,
                                buttonLabel: 'إعادة المحاولة',
                                onPressed: () =>
                                    context.read<KitCubit>().getAllKits(),
                              );
                            }

                            if (state is KitLoaded) {
                              if (state.kits.isEmpty) {
                                return _buildMessageState(
                                  icon: Icons.inbox_outlined,
                                  message: 'لا توجد حزم حالياً.',
                                );
                              }

                              return ListView.separated(
                                itemCount: state.kits.length,
                                separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final kit = state.kits[index];

                                  return LibraryKitCard(
                                    title: kit.name,
                                    description: kit.description,
                                    mindset: kit.mindset,
                                    imageUrl: kit.imageUrl,
                                    rating: kit.rating,
                                    age: kit.age,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => KitDetailsScreen(
                                            kitId: kit.id,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textAlign: TextAlign.right,
        onChanged: (value) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 300), () {
            context.read<KitCubit>().searchKits(value);
          });
        },
        decoration: InputDecoration(
          hintText: 'ابحثي عن تجربة',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildMindsetChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _mindsetFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = _mindsetFilters[index];

          return CategoryChip(
            label: option.label,
            isSelected: _selectedLabel == option.label,
            onTap: () => _onMindsetSelected(option),
          );
        },
      ),
    );
  }

  void _onMindsetSelected(_MindsetFilterOption option) {
    setState(() {
      _selectedLabel = option.label;
    });

    if (_searchController.text.trim().isNotEmpty) {
      _searchController.clear();
    }

    final cubit = context.read<KitCubit>();

    if (option.mindset == null) {
      cubit.getAllKits();
    } else {
      cubit.getKitsByMindset(option.mindset!);
    }
  }

  Widget _buildMessageState({
    required IconData icon,
    required String message,
    String? buttonLabel,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: AppColors.hint),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class _MindsetFilterOption {
  final String label;
  final Mindset? mindset;

  const _MindsetFilterOption({
    required this.label,
    this.mindset,
  });
}