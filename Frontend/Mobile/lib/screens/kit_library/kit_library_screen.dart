import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/config/api_constants.dart';
import '../../core/theme/app_colors.dart';
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
import 'widgets/child_mode_owned_kit_card.dart';
import 'widgets/kit_library_filter_chip.dart';
import 'widgets/kit_library_header.dart';
import 'widgets/kit_library_message_state.dart';
import 'widgets/kit_library_search_field.dart';
import 'widgets/kit_load_more_section.dart';
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

  List<KitModel> _childKits = [];
  bool _childKitsLoading = false;
  bool _childKitsLoadScheduled = false;
  String? _childKitsError;
  int? _selectedChildId;

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
                    ? _buildChildModeContent()
                    : _buildNormalScrollableContent(context, isChildMode),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
      ),
    );
  }

  Widget _buildChildModeContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const KitLibraryHeader(isChildMode: true),
          const SizedBox(height: 16),
          Expanded(child: _buildChildKitsList()),
        ],
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
            KitLibraryHeader(isChildMode: isChildMode),
            const SizedBox(height: 16),
            KitLibrarySearchField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _clearSearchAndRestoreFilter,
            ),
            const SizedBox(height: 12),
            _buildFiltersSection(),
            const SizedBox(height: 14),
            _buildNormalListContent(context, state),
          ],
        );
      },
    );
  }

  Widget _buildNormalListContent(BuildContext context, KitState state) {
    if (state is KitLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is KitError) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: KitLibraryMessageState(
          icon: Icons.error_outline_rounded,
          message: state.message,
          buttonLabel: 'إعادة المحاولة',
          onPressed: _retryCurrentRequest,
        ),
      );
    }

    if (state is KitLoaded && state.kits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: KitLibraryMessageState(
          icon: Icons.inbox_outlined,
          message: _isSearching
              ? 'لا توجد صناديق تطابق بحثك.'
              : 'لا توجد صناديق مطابقة حالياً.',
        ),
      );
    }

    if (state is KitLoaded) {
      return Column(
        children: [
          for (int index = 0; index < state.kits.length; index++) ...[
            LibraryKitCard(
              title: state.kits[index].name,
              description: state.kits[index].description,
              type: state.kits[index].type,
              imageUrl: _kitPreviewImage(state.kits[index]),
              rating: state.kits[index].rating,
              age: state.kits[index].age,
              onTap: () => _openKitDetails(state.kits[index].id),
            ),
            if (index != state.kits.length - 1) const SizedBox(height: 16),
          ],
          const SizedBox(height: 18),
          KitLoadMoreSection(
            hasMore: state.hasMore,
            isLoadingMore: state.isLoadingMore,
            loadMoreError: state.loadMoreError,
            onLoadMore: () => context.read<KitCubit>().loadMoreKits(),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildChildKitsList() {
    if (_childKitsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_childKitsError != null) {
      return KitLibraryMessageState(
        icon: Icons.error_outline_rounded,
        message: _childKitsError!,
        buttonLabel: 'إعادة المحاولة',
        onPressed: _loadChildKits,
      );
    }

    if (_childKits.isEmpty) {
      return const KitLibraryMessageState(
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

        return ChildModeOwnedKitCard(
          name: kit.name,
          imageUrl: _kitPreviewImage(kit),
          type: kit.type,
          rating: kit.rating,
          onTap: () => _openOwnedKit(kit),
        );
      },
    );
  }

  Widget _buildFiltersSection() {
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
                KitLibraryFilterChip(
                  label: 'الكل',
                  isSelected:
                      !_isSearching && _selectedFilterKey == _FilterKeys.all,
                  color: AppColors.yellow,
                  onTap: _selectAllKits,
                ),
                const SizedBox(width: 8),
                KitLibraryFilterChip(
                  label: 'استكشاف',
                  isSelected: !_isSearching &&
                      _selectedFilterKey ==
                          _FilterKeys.type(KitType.discovery.apiValue),
                  color: AppColors.primary,
                  onTap: () => _selectType(KitType.discovery),
                ),
                const SizedBox(width: 8),
                KitLibraryFilterChip(
                  label: 'الهواية',
                  isSelected: !_isSearching &&
                      _selectedFilterKey ==
                          _FilterKeys.type(KitType.hobby.apiValue),
                  color: AppColors.pink,
                  onTap: () => _selectType(KitType.hobby),
                ),
                const SizedBox(width: 8),
                KitLibraryFilterChip(
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

  void _openKitDetails(int kitId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KitDetailsScreen(kitId: kitId),
      ),
    );
  }

  void _openOwnedKit(KitModel kit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OwnedKitScreen(
          kit: kit,
          childId: _selectedChildId,
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
