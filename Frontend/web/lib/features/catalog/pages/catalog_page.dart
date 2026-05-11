// lib/features/catalog/pages/catalog_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/kit/kit_cubit.dart';
import '../cubits/kit/kit_state.dart';
import '../../../shared/models/kit_model.dart';
import '../../../shared/components/footer/footer.dart';
import '../../../shared/components/sections/catalog_sidebar.dart';
import '../../../shared/i18n/catalog_translations.dart';
import '../../../util/theme/app_colors.dart';

// ─── Catalog Page ─────────────────────────────────────────────────────────────
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ScrollController _scrollController = ScrollController();
  String _lang = 'en';
  Set<String> _favorites = {};
  String _sortBy = 'default';

  CatalogFilters _uiFilters = const CatalogFilters(
    selectedAge: null,
    selectedGoals: {},
    maxPrice: 200,
  );

  String? _activeFilterType;

  bool get isAr => _lang == 'ar';
  TextDirection get _dir => isAr ? TextDirection.rtl : TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    context.read<KitCubit>().getAllKits(page: 0);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<KitCubit>().state;
      if (state is KitLoaded && state.hasMore) {
        context.read<KitCubit>().loadNextPage();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ── Filter handlers ────────────────────────────────────────────────────────
  void _onTypeSelected(KitType type) {
    setState(() => _activeFilterType = 'type');
    context.read<KitCubit>().getKitsByType(type);
  }

  void _onMindsetSelected(int mindsetId) {
    setState(() => _activeFilterType = 'mindset');
    context.read<KitCubit>().getKitsByMindset(mindsetId);
  }

  void _onClearFilters() {
    setState(() => _activeFilterType = null);
    context.read<KitCubit>().getAllKits(page: 0);
  }

  void _onSearchChanged(String keyword) {
    setState(() => _activeFilterType = keyword.isEmpty ? null : 'search');
    context.read<KitCubit>().searchKitsDebounced(keyword);
  }

  void _clearSearch() {
    setState(() => _activeFilterType = null);
    context.read<KitCubit>().getAllKits(page: 0);
  }

  void _onFiltersChanged(CatalogFilters f) {
    setState(() => _uiFilters = f);
  }

  void _navigateToHome() => Navigator.pushReplacementNamed(context, '/');

  void _navigateTo(String route) {
    if (route == 'home') {
      _navigateToHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Navigate to: $route'),
            duration: const Duration(seconds: 1)),
      );
    }
  }

  // ── Client-side filter ─────────────────────────────────────────────────────
  List<KitModel> _applyClientFilters(List<KitModel> kits) {
    var list = kits.where((kit) {
      if (kit.price > _uiFilters.maxPrice) return false;
      return true;
    }).toList();

    if (_sortBy == 'newest') {
      list.sort((a, b) {
        if (a.isNew && !b.isNew) return -1;
        if (!a.isNew && b.isNew) return 1;
        return 0;
      });
    } else if (_sortBy == 'favorites') {
      list = list.where((k) => _favorites.contains(k.id.toString())).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 1024;
    final isTablet = w >= 640 && w < 1024;

    return Directionality(
      textDirection: _dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        endDrawer: isDesktop
            ? null
            : Drawer(
                child: SafeArea(
                  child: _MobileDrawer(
                    lang: _lang,
                    filters: _uiFilters,
                    onFiltersChanged: _onFiltersChanged,
                    onNavigate: _navigateTo,
                    onNavigateHome: _navigateToHome,
                    onToggleLang: () =>
                        setState(() => _lang = isAr ? 'en' : 'ar'),
                    onTypeSelected: _onTypeSelected,
                    onMindsetSelected: _onMindsetSelected, // ✅
                    onClearFilters: _onClearFilters,       // ✅
                  ),
                ),
              ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _CatalogNavbar(
                scrollController: _scrollController,
                lang: _lang,
                isDesktop: isDesktop,
                onToggleLang: () =>
                    setState(() => _lang = isAr ? 'en' : 'ar'),
                onNavigate: _navigateTo,
                onNavigateHome: _navigateToHome,
                onSearchChanged: _onSearchChanged,
                onClearSearch: _clearSearch,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : 20,
                  vertical: 32,
                ),
                child: isDesktop
                    ? Row(
                        textDirection: _dir,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CatalogSidebar(
                            lang: _lang,
                            onFiltersChanged: _onFiltersChanged,
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            child: _buildContent(
                                isTablet: isTablet, isDesktop: isDesktop),
                          ),
                        ],
                      )
                    : _buildContent(
                        isTablet: isTablet, isDesktop: isDesktop),
              ),
              Footer(scrollController: _scrollController),
            ],
          ),
        ),
      ),
    );
  }

  // ── Main content ───────────────────────────────────────────────────────────
  Widget _buildContent({required bool isTablet, required bool isDesktop}) {
    return BlocBuilder<KitCubit, KitState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment:
              isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _buildHeader(state),
            const SizedBox(height: 28),
            _buildBody(state, isTablet: isTablet, isDesktop: isDesktop),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(KitState state) {
    return Row(
      textDirection: _dir,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                t('catalog_title', _lang),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t('catalog_subtitle', _lang),
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13, height: 1.5),
                textAlign: isAr ? TextAlign.right : TextAlign.left,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            borderRadius: BorderRadius.circular(12),
            items: [
              DropdownMenuItem(
                  value: 'default',
                  child: Text(isAr ? 'الافتراضي' : 'Default')),
              DropdownMenuItem(
                  value: 'newest',
                  child: Text(isAr ? 'أحدث الوصولات' : 'Newest Arrivals')),
              DropdownMenuItem(
                  value: 'favorites',
                  child: Text(isAr ? 'المفضلات' : 'Favorites')),
            ],
            onChanged: (value) =>
                setState(() => _sortBy = value ?? 'default'),
          ),
        ),
      ],
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(KitState state,
      {required bool isTablet, required bool isDesktop}) {
    if (state is KitLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: CircularProgressIndicator(color: AppColors.teal),
        ),
      );
    }

    if (state is KitError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(
                state.message == 'Unauthorized'
                    ? Icons.lock_outline
                    : Icons.error_outline,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(state.message,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600])),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () =>
                    context.read<KitCubit>().getAllKits(page: 0),
                child: const Text('Retry',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (state is KitLoaded || state is KitLoadingMore) {
      final kits = state is KitLoaded
          ? state.kits
          : (state as KitLoadingMore).currentKits;

      final filtered = _applyClientFilters(kits);

      if (filtered.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            children: [
              Icon(Icons.filter_alt_off, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                isAr
                    ? 'لا توجد نتائج تطابق الفلاتر المختارة'
                    : 'No kits match your selected filters',
                style: TextStyle(color: Colors.grey[500], fontSize: 15),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          _buildGrid(filtered, isTablet: isTablet, isDesktop: isDesktop),
          if (state is KitLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: AppColors.teal),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // ── Grid ───────────────────────────────────────────────────────────────────
  Widget _buildGrid(List<KitModel> kits,
      {required bool isTablet, required bool isDesktop}) {
    final cols = isDesktop ? 3 : (isTablet ? 2 : 1);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.60,
      ),
      itemCount: kits.length,
      itemBuilder: (_, i) {
        final k = kits[i];
        final favKey = k.id.toString();
        return _KitCard(
          kit: k,
          lang: _lang,
          isFav: _favorites.contains(favKey),
          onFavToggle: () => setState(() {
            _favorites.contains(favKey)
                ? _favorites.remove(favKey)
                : _favorites.add(favKey);
          }),
          onTap: () => Navigator.pushNamed(
            context,
            '/kit-details',
            arguments: k.id,
          ),
        );
      },
    );
  }
}

// ─── Kit Card ─────────────────────────────────────────────────────────────────
class _KitCard extends StatefulWidget {
  final KitModel kit;
  final String lang;
  final bool isFav;
  final VoidCallback onFavToggle;
  final VoidCallback onTap;

  const _KitCard({
    required this.kit,
    required this.lang,
    required this.isFav,
    required this.onFavToggle,
    required this.onTap,
  });

  @override
  State<_KitCard> createState() => _KitCardState();
}

class _KitCardState extends State<_KitCard> {
  bool _hovering = false;

  bool get isAr => widget.lang == 'ar';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _hovering
              ? (Matrix4.identity()..translate(0.0, -6.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovering ? 0.10 : 0.05),
                blurRadius: _hovering ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28)),
                      child: widget.kit.imageURL.isNotEmpty
                          ? Image.network(
                              widget.kit.imageURL,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _imagePlaceholder(),
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return _imageLoading();
                              },
                            )
                          : _imagePlaceholder(),
                    ),
                    if (widget.kit.isNew)
                      Positioned(
                        top: 12,
                        right: isAr ? null : 12,
                        left: isAr ? 12 : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4D6D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            t('new_arrival', widget.lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: isAr
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.kit.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          widget.kit.description,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign:
                              isAr ? TextAlign.right : TextAlign.left,
                        ),
                      ),
                      Row(
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              widget.kit.type,
                              style: const TextStyle(
                                color: AppColors.teal,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\$${widget.kit.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      '${t('add_to_cart', widget.lang)}: ${widget.kit.name}'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: AppColors.teal,
                                ));
                              },
                              icon: const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 14),
                              label: Text(
                                t('add_to_cart', widget.lang),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: widget.onFavToggle,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: widget.isFav
                                    ? const Color(0xFFFFE4E8)
                                    : Colors.grey.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                                color: widget.isFav
                                    ? const Color(0xFFFF4D6D)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: Colors.grey[200],
        child: const Center(
            child: Icon(Icons.image_not_supported,
                size: 40, color: Colors.grey)),
      );

  Widget _imageLoading() => Container(
        color: Colors.grey[100],
        child: const Center(
            child: CircularProgressIndicator(
                color: AppColors.teal, strokeWidth: 2)),
      );
}

// ─── Navbar ───────────────────────────────────────────────────────────────────
class _CatalogNavbar extends StatefulWidget {
  final ScrollController scrollController;
  final String lang;
  final bool isDesktop;
  final VoidCallback onToggleLang;
  final void Function(String route) onNavigate;
  final VoidCallback onNavigateHome;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;

  const _CatalogNavbar({
    required this.scrollController,
    required this.lang,
    required this.isDesktop,
    required this.onToggleLang,
    required this.onNavigate,
    required this.onNavigateHome,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  State<_CatalogNavbar> createState() => _CatalogNavbarState();
}

class _CatalogNavbarState extends State<_CatalogNavbar> {
  late final TextEditingController _textController;
  Timer? _debounce;
  String _hoveredLink = '';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        widget.onSearchChanged(_textController.text);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    super.dispose();
  }

  bool get isAr => widget.lang == 'ar';

  Widget _logo() => GestureDetector(
        onTap: widget.onNavigateHome,
        child: Image.asset('assets/images/logo.png',
            height: 44, fit: BoxFit.contain),
      );

  Widget _searchField({double? width}) {
    final hasText = _textController.text.isNotEmpty;
    return Container(
      width: width,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24),
        border: hasText ? Border.all(color: AppColors.teal, width: 1.5) : null,
      ),
      child: TextField(
        controller: _textController,
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        cursorColor: AppColors.teal,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        decoration: InputDecoration(
          hintText: isAr
              ? 'استكشف مغامرات التعلم...'
              : 'Explore learning adventures...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon:
              Icon(Icons.search, size: 18, color: Colors.grey[500]),
          suffixIcon: hasText
              ? IconButton(
                  icon:
                      Icon(Icons.close, size: 16, color: Colors.grey[500]),
                  onPressed: () {
                    _textController.clear();
                    widget.onClearSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
      ),
    );
  }

  Widget _langBtn() => GestureDetector(
        onTap: widget.onToggleLang,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.teal.withOpacity(0.3)),
          ),
          child: Text(
            isAr ? 'EN' : 'AR',
            style: const TextStyle(
                color: AppColors.teal,
                fontSize: 11,
                fontWeight: FontWeight.w700),
          ),
        ),
      );

  Widget _navLink(String label, String id,
      {bool active = false, required VoidCallback onTap}) {
    final isHovered = _hoveredLink == id;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredLink = id),
      onExit: (_) => setState(() => _hoveredLink = ''),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(
            fontSize: 14,
            fontWeight:
                isHovered || active ? FontWeight.w700 : FontWeight.w400,
            color: isHovered || active ? AppColors.teal : Colors.black87,
            decoration: isHovered || active
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: AppColors.teal,
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: widget.isDesktop ? _desktop() : _mobile(context),
    );
  }

  Widget _desktop() {
    return Row(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
        _logo(),
        const SizedBox(width: 32),
        _navLink('Home', 'home', onTap: widget.onNavigateHome),
        _navLink('Kits', 'kits',
            active: true, onTap: () => widget.onNavigate('kits')),
        _navLink('Subjects', 'subjects',
            onTap: () => widget.onNavigate('subjects')),
        _navLink('Educators', 'educators',
            onTap: () => widget.onNavigate('educators')),
        _navLink('Our Story', 'story',
            onTap: () => widget.onNavigate('story')),
        _navLink('Blog', 'blog', onTap: () => widget.onNavigate('blog')),
        const Spacer(),
        _searchField(width: 280),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, size: 22),
          onPressed: () => widget.onNavigate('cart'),
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, size: 22),
          onPressed: () => widget.onNavigate('account'),
        ),
        const SizedBox(width: 8),
        _langBtn(),
      ],
    );
  }

  Widget _mobile(BuildContext context) {
    return Column(
      children: [
        Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _logo(),
            Row(children: [
              _langBtn(),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 22),
                onPressed: () => widget.onNavigate('cart'),
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined, size: 22),
                onPressed: () => widget.onNavigate('account'),
              ),
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                ),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 10),
        _searchField(),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ─── Mobile Drawer ────────────────────────────────────────────────────────────
class _MobileDrawer extends StatefulWidget {
  final String lang;
  final CatalogFilters filters;
  final void Function(CatalogFilters) onFiltersChanged;
  final void Function(String route) onNavigate;
  final VoidCallback onNavigateHome;
  final VoidCallback onToggleLang;
  final void Function(KitType) onTypeSelected;
  final void Function(int mindsetId) onMindsetSelected; // ✅
  final VoidCallback onClearFilters;                    // ✅

  const _MobileDrawer({
    required this.lang,
    required this.filters,
    required this.onFiltersChanged,
    required this.onNavigate,
    required this.onNavigateHome,
    required this.onToggleLang,
    required this.onTypeSelected,
    required this.onMindsetSelected, // ✅
    required this.onClearFilters,    // ✅
  });

  @override
  State<_MobileDrawer> createState() => _MobileDrawerState();
}

class _MobileDrawerState extends State<_MobileDrawer> {
  bool get isAr => widget.lang == 'ar';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logo.png',
                    height: 40, fit: BoxFit.contain),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _link('Home',
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onNavigateHome();
                    }),
                _link('Kits',
                    isActive: true,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onNavigate('kits');
                    }),
                _link('Subjects',
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onNavigate('subjects');
                    }),
                _link('Educators',
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onNavigate('educators');
                    }),
                _link('Our Story',
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onNavigate('story');
                    }),
                _link('Blog',
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onNavigate('blog');
                    }),
              ],
            ),
          ),
          Divider(color: Colors.grey[200], height: 32),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CatalogSidebar(
                lang: widget.lang,
                onFiltersChanged: widget.onFiltersChanged,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () {
                widget.onToggleLang();
                setState(() {});
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.teal.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? 'العربية' : 'English',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        isAr ? 'EN' : 'AR',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _link(String title,
      {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.teal.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.teal : Colors.black87,
          ),
        ),
      ),
    );
  }
}