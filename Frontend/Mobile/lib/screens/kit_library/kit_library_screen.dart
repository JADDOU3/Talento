import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/config/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';
import '../../cubits/child_mode/child_mode_state.dart';
import '../../cubits/kit/kit_cubit.dart';
import '../../cubits/kit/kit_state.dart';
import '../../models/kit/kit_enums.dart';
import '../../models/kit/kit_model.dart';
import '../../services/kit/kit_service.dart';
import '../../services/profile/profile_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/app_drawer.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/layout/top_bar.dart';
import '../owned_kit/owned_kit_screen.dart';
import 'kit_details_screen.dart';
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
  String _selectedFilterKey = _FilterKeys.all;
  bool _isSearching = false;

  // Child mode kits state kept untouched for now.
  // The child-mode restriction will be handled in a separate safe step.
  List<KitModel> _childKits = [];
  bool _childKitsLoading = false;
  bool _childKitsLoadScheduled = false;
  String? _childKitsError;
  int? _selectedChildId;

  void _scheduleChildKitsLoadIfNeeded(bool isChildMode) {
    if (!isChildMode ||
        _childKitsLoading ||
        _childKitsLoadScheduled ||
        _childKits.isNotEmpty) {
      return;
    }

    _childKitsLoadScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _childKitsLoadScheduled = false;

      final childModeState = context.read<ChildModeCubit>().state;
      final stillInChildMode =
          childModeState is ChildModeStatus && childModeState.isChildMode;

      if (stillInChildMode && _childKits.isEmpty && !_childKitsLoading) {
        _loadChildKits();
      }
    });
  }

  Future<void> _loadChildKits() async {
    setState(() {
      _childKitsLoading = true;
      _childKitsError = null;
    });

    try {
      final service = ProfileService();
      final selectedChild = await service.getSelectedChild();

      if (!mounted) return;

      if (selectedChild == null) {
        setState(() {
          _selectedChildId = null;
          _childKits = [];
          _childKitsLoading = false;
        });
        return;
      }

      final kits = await service.getKitsByChild(selectedChild.id);

      if (!mounted) return;

      setState(() {
        _selectedChildId = selectedChild.id;
        _childKits = kits;
        _childKitsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _childKitsError = e.toString();
        _childKitsLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childModeState = context.watch<ChildModeCubit>().state;
    final isChildMode =
        childModeState is ChildModeStatus && childModeState.isChildMode;

    _scheduleChildKitsLoadIfNeeded(isChildMode);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const AppDrawer(),
        body: AppBackground(
          child: Column(
            children: [
              const TopBar(),
              Expanded(
                child: isChildMode
                    ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildHeader(isChildMode),
                      const SizedBox(height: 16),
                      Expanded(child: _buildChildKitsList()),
                    ],
                  ),
                )
                    : _buildNormalScrollableContent(context, isChildMode),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
      ),
    );
  }

  Widget _buildNormalScrollableContent(
      BuildContext context,
      bool isChildMode,
      ) {
    return BlocBuilder<KitCubit, KitState>(
      builder: (context, state) {
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          children: [
            _buildHeader(isChildMode),
            const SizedBox(height: 16),
            _buildSearchField(context),
            const SizedBox(height: 12),
            _buildFiltersSection(),
            const SizedBox(height: 14),

            if (state is KitLoading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state is KitError)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: _buildMessageState(
                  icon: Icons.error_outline_rounded,
                  message: state.message,
                  buttonLabel: 'إعادة المحاولة',
                  onPressed: _retryCurrentRequest,
                ),
              )
            else if (state is KitLoaded && state.kits.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: _buildMessageState(
                    icon: Icons.inbox_outlined,
                    message: _isSearching
                        ? 'لا توجد صناديق تطابق بحثك.'
                        : 'لا توجد صناديق مطابقة حالياً.',
                  ),
                )
              else if (state is KitLoaded)
                  ...[
                    for (int index = 0; index < state.kits.length; index++) ...[
                      LibraryKitCard(
                        title: state.kits[index].name,
                        description: state.kits[index].description,
                        type: state.kits[index].type,
                        imageUrl: _kitPreviewImage(state.kits[index]),
                        rating: state.kits[index].rating,
                        age: state.kits[index].age,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KitDetailsScreen(
                              kitId: state.kits[index].id,
                            ),
                          ),
                        ),
                      ),
                      if (index != state.kits.length - 1)
                        const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 18),
                    _buildLoadMoreSection(state),
                  ],
          ],
        );
      },
    );
  }

  Widget _buildLoadMoreSection(KitLoaded state) {
    if (!state.hasMore && state.loadMoreError == null) {
      return const SizedBox.shrink();
    }

    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    if (state.loadMoreError != null) {
      return Column(
        children: [
          Text(
            state.loadMoreError!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _loadMoreButton(),
        ],
      );
    }

    return _loadMoreButton();
  }

  Widget _loadMoreButton() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.read<KitCubit>().loadMoreKits(),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Center(
              child: Text(
                'تحميل المزيد',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isChildMode) {
    return Container(
      width: double.infinity,
      height: 118,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFDFF6F3),
            Color(0xFFF7FFFE),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.transparent,
                      const Color(0xFFCCF1EC).withValues(alpha: 0.18),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  _buildHeaderWordCloud(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isChildMode ? 'صناديقي' : 'مكتبة الصناديق',
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: const Color(0xFF087C78),
                              fontSize: 23.5,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isChildMode
                                ? 'كل الصناديق المتاحة لطفلك في مكان واحد'
                                : 'استكشف صناديق تعليمية ممتعة لتنمية مهارات طفلك',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWordCloud() {
    return SizedBox(
      width: 98,
      height: 82,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 26,
            child: _headerFloatingTag(
              text: 'متعة',
              color: AppColors.pink,
              width: 54,
              height: 26,
            ),
          ),
          Positioned(
            top: 26,
            left: 0,
            child: Transform.rotate(
              angle: -0.06,
              child: _headerFloatingTag(
                text: 'تعلم',
                color: AppColors.yellow,
                width: 52,
                height: 26,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 22,
            child: _headerFloatingTag(
              text: 'اكتشاف',
              color: AppColors.primary,
              width: 62,
              height: 27,
            ),
          ),
          Positioned(
            top: -2,
            left: 10,
            child: _headerSparkle(AppColors.yellow, 10),
          ),
          Positioned(
            top: 10,
            left: 82,
            child: _headerSparkle(AppColors.pink, 8),
          ),
          Positioned(
            top: 39,
            left: 62,
            child: _tinyBubble(AppColors.primary, 5),
          ),
          Positioned(
            top: 18,
            left: 18,
            child: _tinyBubble(AppColors.pink, 4),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: _headerSparkle(AppColors.yellow, 9),
          ),
          Positioned(
            bottom: 10,
            left: 86,
            child: _tinyBubble(AppColors.secondary, 5),
          ),
        ],
      ),
    );
  }

  Widget _headerFloatingTag({
    required String text,
    required Color color,
    required double width,
    required double height,
  }) {
    final textColor =
    color == AppColors.yellow ? const Color(0xFFD59A00) : color;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor,
            fontSize: 10.8,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _headerSparkle(Color color, double size) {
    return Icon(
      Icons.star_rounded,
      color: color.withValues(alpha: 0.82),
      size: size,
    );
  }

  Widget _tinyBubble(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
    );
  }

  String _kitPreviewImage(KitModel kit) {
    final images = [
      kit.imageUrl,
      ...kit.imageUrls,
    ];

    for (final image in images) {
      final normalizedImage = _normalizeImageUrl(image);

      if (normalizedImage.isNotEmpty) {
        return normalizedImage;
      }
    }

    return '';
  }

  String _normalizeImageUrl(String value) {
    final image = value.trim();

    if (image.isEmpty) return '';

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    final cleanBaseUrl = ApiConstants.baseUrl
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceFirst(RegExp(r'/$'), '');

    final cleanImagePath = image.startsWith('/') ? image.substring(1) : image;

    return '$cleanBaseUrl/$cleanImagePath';
  }

  Widget _buildChildKitsList() {
    if (_childKitsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_childKitsError != null) {
      return _buildMessageState(
        icon: Icons.error_outline_rounded,
        message: _childKitsError!,
        buttonLabel: 'إعادة المحاولة',
        onPressed: _loadChildKits,
      );
    }

    if (_childKits.isEmpty) {
      return _buildMessageState(
        icon: Icons.inbox_outlined,
        message: 'لا توجد صناديق مملوكة حتى الآن',
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _childKits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final kit = _childKits[index];

        return LibraryKitCard(
          title: kit.name,
          description: kit.description,
          type: kit.type,
          imageUrl: _kitPreviewImage(kit),
          rating: kit.rating,
          age: kit.age,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OwnedKitScreen(
                kit: kit,
                childId: _selectedChildId,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textAlign: TextAlign.right,
        textInputAction: TextInputAction.search,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'ابحث عن صندوق',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.hint,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          suffixIcon: _searchController.text.trim().isEmpty
              ? null
              : IconButton(
            onPressed: _clearSearchAndRestoreFilter,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.hint,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return _buildAllFilterChips();
  }

  Widget _buildAllFilterChips() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: 46,
        width: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _filterChip(
                  label: 'الكل',
                  isSelected:
                  !_isSearching && _selectedFilterKey == _FilterKeys.all,
                  color: AppColors.yellow,
                  onTap: _selectAllKits,
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: 'استكشاف',
                  isSelected: !_isSearching &&
                      _selectedFilterKey ==
                          _FilterKeys.type(KitType.discovery.apiValue),
                  color: AppColors.primary,
                  onTap: () => _selectType(KitType.discovery),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: 'الهواية',
                  isSelected: !_isSearching &&
                      _selectedFilterKey ==
                          _FilterKeys.type(KitType.hobby.apiValue),
                  color: AppColors.pink,
                  onTap: () => _selectType(KitType.hobby),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: 'التطوير',
                  isSelected: !_isSearching &&
                      _selectedFilterKey ==
                          _FilterKeys.type(KitType.development.apiValue),
                  color: AppColors.secondary,
                  onTap: () => _selectType(KitType.development),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _filterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
    Color? selectedTextColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: isSelected
                  ? color
                  : AppColors.border.withValues(alpha: 0.75),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withValues(alpha: 0.18)
                    : AppColors.black.withValues(alpha: 0.025),
                blurRadius: isSelected ? 10 : 7,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected
                    ? (selectedTextColor ?? AppColors.white)
                    : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final keyword = value.trim();

    setState(() {
      _isSearching = keyword.isNotEmpty;
    });

    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;

      if (keyword.isEmpty) {
        _applySelectedFilter();
      } else {
        context.read<KitCubit>().searchKits(keyword);
      }
    });
  }

  void _clearSearchAndRestoreFilter() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() => _isSearching = false);
    _applySelectedFilter();
  }

  void _clearSearchSilently() {
    _debounce?.cancel();

    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
    }

    _isSearching = false;
  }

  void _selectAllKits() {
    setState(() {
      _clearSearchSilently();
      _selectedFilterKey = _FilterKeys.all;
    });

    context.read<KitCubit>().getAllKits();
  }

  void _selectType(KitType type) {
    setState(() {
      _clearSearchSilently();
      _selectedFilterKey = _FilterKeys.type(type.apiValue);
    });

    context.read<KitCubit>().getKitsByType(type.apiValue);
  }

  void _applySelectedFilter() {
    final cubit = context.read<KitCubit>();

    if (_selectedFilterKey == _FilterKeys.all) {
      cubit.getAllKits();
      return;
    }

    if (_selectedFilterKey.startsWith(_FilterKeys.typePrefix)) {
      final type = _selectedFilterKey.replaceFirst(
        _FilterKeys.typePrefix,
        '',
      );

      if (type.isNotEmpty) {
        cubit.getKitsByType(type);
        return;
      }
    }

    cubit.getAllKits();
  }

  void _retryCurrentRequest() {
    final keyword = _searchController.text.trim();

    if (_isSearching && keyword.isNotEmpty) {
      context.read<KitCubit>().searchKits(keyword);
    } else {
      _applySelectedFilter();
    }
  }

  Widget _buildMessageState({
    required IconData icon,
    required String message,
    String? buttonLabel,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: AppColors.hint,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(buttonLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterKeys {
  static const String all = 'all';
  static const String typePrefix = 'type-';

  static String type(String value) => '$typePrefix$value';
}