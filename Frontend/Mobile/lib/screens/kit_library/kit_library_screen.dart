import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/kit/kit_cubit.dart';
import '../../cubits/kit/kit_state.dart';
import '../../models/kit_enums.dart';
import '../../services/kit_service.dart';
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

  String _selectedFilterGroup = 'ALL';
  String _selectedFilterLabel = 'الكل';

  final List<_FilterOption> _typeFilters = const [
    _FilterOption(label: 'الكل', group: 'ALL'),
    _FilterOption(label: 'DISCOVERY', group: 'TYPE', type: KitType.discovery),
    _FilterOption(label: 'HOBBY', group: 'TYPE', type: KitType.hobby),
    _FilterOption(
      label: 'DEVELOPMENT',
      group: 'TYPE',
      type: KitType.development,
    ),
  ];

  final List<_FilterOption> _mindsetFilters = const [
    _FilterOption(
      label: 'BUILDER',
      group: 'MINDSET',
      mindset: Mindset.builder,
    ),
    _FilterOption(
      label: 'SCIENTIST',
      group: 'MINDSET',
      mindset: Mindset.scientist,
    ),
    _FilterOption(
      label: 'EXPLORER',
      group: 'MINDSET',
      mindset: Mindset.explorer,
    ),
    _FilterOption(
      label: 'INVENTOR',
      group: 'MINDSET',
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
    return Scaffold(
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
                    _buildSearchField(context),
                    const SizedBox(height: 14),
                    _buildSectionTitle('Type'),
                    const SizedBox(height: 8),
                    _buildFilterChips(_typeFilters),
                    const SizedBox(height: 12),
                    _buildSectionTitle('Mindset'),
                    const SizedBox(height: 8),
                    _buildFilterChips(_mindsetFilters),
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
                              onPressed:
                                  () => context.read<KitCubit>().getAllKits(),
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
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final kit = state.kits[index];

                                return LibraryKitCard(
                                  title: kit.name,
                                  description: kit.description,
                                  category: kit.type,
                                  imageUrl: kit.imageUrl,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => KitDetailsScreen(
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
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      textAlign: TextAlign.right,
      onChanged: (value) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          context.read<KitCubit>().searchKits(value);
        });
      },
      decoration: InputDecoration(
        hintText: 'ابحث عن تجربة',
        prefixIcon: const Icon(Icons.search, color: AppColors.yellow),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildFilterChips(List<_FilterOption> options) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected =
              _selectedFilterGroup == option.group &&
                  _selectedFilterLabel == option.label;

          return CategoryChip(
            label: option.label,
            isSelected: isSelected,
            onTap: () => _onFilterSelected(option),
          );
        },
      ),
    );
  }

  void _onFilterSelected(_FilterOption option) {
    setState(() {
      _selectedFilterGroup = option.group;
      _selectedFilterLabel = option.label;
    });

    if (_searchController.text.trim().isNotEmpty) {
      _searchController.clear();
    }

    final cubit = context.read<KitCubit>();

    if (option.group == 'ALL') {
      cubit.getAllKits();
      return;
    }

    if (option.type != null) {
      cubit.getKitsByType(option.type!);
      return;
    }

    if (option.mindset != null) {
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
          Icon(icon, size: 48, color: AppColors.hint),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ],
      ),
    );
  }
}

class _FilterOption {
  final String label;
  final String group;
  final KitType? type;
  final Mindset? mindset;

  const _FilterOption({
    required this.label,
    required this.group,
    this.type,
    this.mindset,
  });
}