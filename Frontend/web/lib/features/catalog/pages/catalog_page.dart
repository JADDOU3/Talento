// lib/features/catalog/pages/catalog_page.dart

import 'package:flutter/material.dart';
import '../../../shared/components/footer/footer.dart';
import '../../../shared/components/sections/catalog_sidebar.dart';
import '../../../shared/components/cards/kit_card.dart';
import '../../../shared/i18n/catalog_translations.dart';
import '../../../util/theme/app_colors.dart';

// ─── Kit model with unique ID ────────────────────────────────────────────────
class _KitData {
  final String id;
  final String imagePath;
  final String titleKey;
  final String descKey;
  final String ageKey;
  final String goalKey;
  final String agePillKey;
  final double price;
  final bool isNew;

  const _KitData({
    required this.id,
    required this.imagePath,
    required this.titleKey,
    required this.descKey,
    required this.ageKey,
    required this.goalKey,
    required this.agePillKey,
    required this.price,
    this.isNew = false,
  });
}

// ── All kits ───────────────────────────────────────────────────────────────────
const List<_KitData> _allKits = [
  _KitData(
    id: 'kit_1',
    imagePath: 'assets/images/img5.png',
    titleKey: 'kit1_title',
    descKey: 'kit1_desc',
    ageKey: 'kit1_age',
    goalKey: 'natural_sciences',
    agePillKey: 'age_6_8',
    price: 45.00,
  ),
  _KitData(
    id: 'kit_2',
    imagePath: 'assets/images/img6.png',
    titleKey: 'kit2_title',
    descKey: 'kit2_desc',
    ageKey: 'kit2_age',
    goalKey: 'logical_reasoning',
    agePillKey: 'age_3_5',
    price: 59.00,
  ),
  _KitData(
    id: 'kit_3',
    imagePath: 'assets/images/img7.png',
    titleKey: 'kit3_title',
    descKey: 'kit3_desc',
    ageKey: 'kit3_age',
    goalKey: 'natural_sciences',
    agePillKey: 'age_9_12',
    price: 68.00,
    isNew: true,
  ),
  _KitData(
    id: 'kit_4',
    imagePath: 'assets/images/img8.png',
    titleKey: 'kit4_title',
    descKey: 'kit4_desc',
    ageKey: 'kit4_age',
    goalKey: 'creative_arts',
    agePillKey: 'age_6_8',
    price: 32.00,
  ),
  _KitData(
    id: 'kit_5',
    imagePath: 'assets/images/img1.jpg',
    titleKey: 'kit5_title',
    descKey: 'kit5_desc',
    ageKey: 'kit5_age',
    goalKey: 'sustainability',
    agePillKey: 'age_9_12',
    price: 89.00,
  ),
  _KitData(
    id: 'kit_6',
    imagePath: 'assets/images/img2.jpg',
    titleKey: 'kit6_title',
    descKey: 'kit6_desc',
    ageKey: 'kit6_age',
    goalKey: 'natural_sciences',
    agePillKey: 'age_teens',
    price: 110.00,
  ),
  _KitData(
    id: 'kit_7',
    imagePath: 'assets/images/img3.jpg',
    titleKey: 'kit7_title',
    descKey: 'kit7_desc',
    ageKey: 'kit7_age',
    goalKey: 'logical_reasoning',
    agePillKey: 'age_9_12',
    price: 52.00,
    isNew: true,
  ),
  _KitData(
    id: 'kit_8',
    imagePath: 'assets/images/img4.jpg',
    titleKey: 'kit8_title',
    descKey: 'kit8_desc',
    ageKey: 'kit8_age',
    goalKey: 'sustainability',
    agePillKey: 'age_6_8',
    price: 47.00,
  ),
];

// ─── Page ─────────────────────────────────────────────────────────────────────
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
  String _searchQuery = '';

  int _currentPage = 1;
  static const int _kitsPerPage = 6;

  CatalogFilters _filters = const CatalogFilters(
    selectedAge: null,
    selectedGoals: {},
    maxPrice: 200,
  );

  bool get isAr => _lang == 'ar';
  TextDirection get _dir => isAr ? TextDirection.rtl : TextDirection.ltr;

  String _getKitTitle(_KitData kit) => t(kit.titleKey, _lang);
  String _getKitDesc(_KitData kit) => t(kit.descKey, _lang);

  List<_KitData> get _filteredKits {
    var list = _allKits.where((kit) {
      if (kit.price > _filters.maxPrice) return false;
      if (_filters.selectedAge != null &&
          kit.agePillKey != _filters.selectedAge) return false;
      if (_filters.selectedGoals.isNotEmpty &&
          !_filters.selectedGoals.contains(kit.goalKey)) return false;
      
      if (_searchQuery.isNotEmpty) {
        final title = _getKitTitle(kit).toLowerCase();
        final desc = _getKitDesc(kit).toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!title.contains(query) && !desc.contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();

    if (_sortBy == 'newest') {
      list.sort((a, b) {
        if (a.isNew && !b.isNew) return -1;
        if (!a.isNew && b.isNew) return 1;
        return 0;
      });
    } else if (_sortBy == 'favorites') {
      list = list.where((kit) => _favorites.contains(kit.id)).toList();
    }

    return list;
  }

  List<_KitData> get _pageKits {
    final all = _filteredKits;
    final start = (_currentPage - 1) * _kitsPerPage;
    final end = (start + _kitsPerPage).clamp(0, all.length);
    if (start >= all.length) return [];
    return all.sublist(start, end);
  }

  int get _totalPages {
    final count = _filteredKits.length;
    if (count == 0) return 1;
    return (count / _kitsPerPage).ceil();
  }

  void _onFiltersChanged(CatalogFilters f) {
    setState(() {
      _filters = f;
      _currentPage = 1;
    });
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _currentPage = 1;
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/');
  }

  void _navigateTo(String route) {
    if (route == 'home') {
      _navigateToHome();
    } else if (route == 'kits') {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else if (route == 'catalog') {
      // Already on catalog page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigate to: $route'), duration: const Duration(seconds: 1)),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                    filters: _filters,
                    onFiltersChanged: _onFiltersChanged,
                    onNavigate: _navigateTo,
                    onNavigateHome: _navigateToHome,
                    onToggleLang: () => setState(() => _lang = isAr ? 'en' : 'ar'),
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
                onToggleLang: () => setState(() => _lang = isAr ? 'en' : 'ar'),
                onNavigate: _navigateTo,
                onNavigateHome: _navigateToHome,
                searchQuery: _searchQuery,
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                    _currentPage = 1;
                  });
                },
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

  Widget _buildContent({required bool isTablet, required bool isDesktop}) {
    final kits = _pageKits;
    return Column(
      crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 28),
        kits.isEmpty
            ? _emptyState()
            : _buildGrid(kits, isTablet: isTablet, isDesktop: isDesktop),
        const SizedBox(height: 40),
        _buildPagination(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _emptyState() {
    String message;
    if (_searchQuery.isNotEmpty) {
      message = isAr 
        ? 'لا توجد نتائج تطابق "$_searchQuery"'
        : 'No results match "$_searchQuery"';
    } else {
      message = isAr
        ? 'لا توجد نتائج تطابق الفلاتر المختارة'
        : 'No kits match your selected filters';
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(_searchQuery.isNotEmpty ? Icons.search_off : Icons.filter_alt_off,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton(
                onPressed: _clearSearch,
                child: Text(
                  isAr ? 'مسح البحث' : 'Clear search',
                  style: const TextStyle(color: AppColors.teal),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      textDirection: _dir,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
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
              DropdownMenuItem(value: 'default', child: Text(isAr ? 'الافتراضي' : 'Default')),
              DropdownMenuItem(value: 'newest', child: Text(isAr ? 'أحدث الوصولات' : 'Newest Arrivals')),
              DropdownMenuItem(value: 'favorites', child: Text(isAr ? 'المفضلات' : 'Favorites')),
            ],
            onChanged: (value) {
              setState(() {
                _sortBy = value ?? 'default';
                _currentPage = 1;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(List<_KitData> kits, {required bool isTablet, required bool isDesktop}) {
    final cols = isDesktop ? 3 : (isTablet ? 2 : 1);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.58,
      ),
      itemCount: kits.length,
      itemBuilder: (_, i) {
        final k = kits[i];
        return KitCard(
          id: k.id,
          imagePath: k.imagePath,
          titleKey: k.titleKey,
          descKey: k.descKey,
          ageKey: k.ageKey,
          price: k.price,
          isNew: k.isNew,
          lang: _lang,
          isFav: _favorites.contains(k.id),
          onFavToggle: () {
            setState(() {
              if (_favorites.contains(k.id)) {
                _favorites.remove(k.id);
              } else {
                _favorites.add(k.id);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: _dir,
      children: [
        _pageBtn(
          child: Icon(isAr ? Icons.chevron_right : Icons.chevron_left, size: 18),
          onTap: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
        ),
        const SizedBox(width: 6),
        ..._pageNumbers(),
        const SizedBox(width: 6),
        _pageBtn(
          child: Icon(isAr ? Icons.chevron_left : Icons.chevron_right, size: 18),
          onTap: _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
        ),
      ],
    );
  }

  List<Widget> _pageNumbers() {
    final widgets = <Widget>[];
    final total = _totalPages;
    final show = <int>{1, total, _currentPage};
    if (_currentPage > 1) show.add(_currentPage - 1);
    if (_currentPage < total) show.add(_currentPage + 1);
    final sorted = show.toList()..sort();
    bool dotAdded = false;

    for (int i = 0; i < sorted.length; i++) {
      final page = sorted[i];
      if (i > 0 && page - sorted[i - 1] > 1) {
        if (!dotAdded) {
          widgets.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text('…', style: TextStyle(color: Colors.black38, fontSize: 15)),
          ));
          widgets.add(const SizedBox(width: 6));
          dotAdded = true;
        }
      } else {
        dotAdded = false;
      }
      widgets.add(_pageBtn(
        child: Text('$page',
            style: TextStyle(
              fontWeight: page == _currentPage ? FontWeight.bold : FontWeight.w400,
              color: page == _currentPage ? Colors.white : Colors.black54,
              fontSize: 13,
            )),
        active: page == _currentPage,
        onTap: () => _goToPage(page),
      ));
      widgets.add(const SizedBox(width: 6));
    }
    return widgets;
  }

  Widget _pageBtn({
    required Widget child,
    bool active = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active ? AppColors.teal : (onTap == null ? Colors.grey.withOpacity(0.1) : Colors.white),
          border: Border.all(
            color: active ? AppColors.teal : (onTap == null ? Colors.black12.withOpacity(0.05) : Colors.black12),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─── Mobile Drawer with Navigation Links AND Filters ──────────────────────────
class _MobileDrawer extends StatefulWidget {
  final String lang;
  final CatalogFilters filters;
  final void Function(CatalogFilters) onFiltersChanged;
  final void Function(String route) onNavigate;
  final VoidCallback onNavigateHome;
  final VoidCallback onToggleLang;

  const _MobileDrawer({
    required this.lang,
    required this.filters,
    required this.onFiltersChanged,
    required this.onNavigate,
    required this.onNavigateHome,
    required this.onToggleLang,
  });

  @override
  State<_MobileDrawer> createState() => _MobileDrawerState();
}

class _MobileDrawerState extends State<_MobileDrawer> {
  String _hoveredLink = '';
  String? _selectedAge;
  final Map<String, bool> _goals = {
    'natural_sciences': false,
    'logical_reasoning': false,
    'creative_arts': false,
    'sustainability': false,
  };
  double _maxPrice = 200;

  bool get isAr => widget.lang == 'ar';

  @override
  void initState() {
    super.initState();
    _selectedAge = widget.filters.selectedAge;
    _maxPrice = widget.filters.maxPrice;
    for (var goal in widget.filters.selectedGoals) {
      if (_goals.containsKey(goal)) {
        _goals[goal] = true;
      }
    }
  }

  void _notifyFiltersChanged() {
    widget.onFiltersChanged(CatalogFilters(
      selectedAge: _selectedAge,
      selectedGoals: _goals.entries.where((e) => e.value).map((e) => e.key).toSet(),
      maxPrice: _maxPrice,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Header with Logo and Close Button
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
                Image.asset('assets/images/logo.png', height: 40, fit: BoxFit.contain),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Navigation Links
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _drawerLink('Home', 'home', isActive: false, onTap: () {
                  Navigator.pop(context);
                  widget.onNavigateHome();
                }),
                const SizedBox(height: 4),
                _drawerLink('Kits', 'kits', isActive: true, onTap: () {
                  Navigator.pop(context);
                  widget.onNavigate('kits');
                }),
                const SizedBox(height: 4),
                _drawerLink('Subjects', 'subjects', isActive: false, onTap: () {
                  Navigator.pop(context);
                  widget.onNavigate('subjects');
                }),
                const SizedBox(height: 4),
                _drawerLink('Educators', 'educators', isActive: false, onTap: () {
                  Navigator.pop(context);
                  widget.onNavigate('educators');
                }),
                const SizedBox(height: 4),
                _drawerLink('Our Story', 'story', isActive: false, onTap: () {
                  Navigator.pop(context);
                  widget.onNavigate('story');
                }),
                const SizedBox(height: 4),
                _drawerLink('Blog', 'blog', isActive: false, onTap: () {
                  Navigator.pop(context);
                  widget.onNavigate('blog');
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Divider
          Container(height: 1, color: Colors.grey[200], margin: const EdgeInsets.symmetric(horizontal: 16)),
          
          const SizedBox(height: 20),
          
          // Filters Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Header
                  Text(
                    t('filter_by', widget.lang),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Age Range Section
                  Text(
                    t('age_range', widget.lang),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAgePills(),
                  const SizedBox(height: 20),
                  
                  // Learning Goals Section
                  Text(
                    t('learning_goal', widget.lang),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLearningGoals(),
                  const SizedBox(height: 20),
                  
                  // Price Range Section
                  Text(
                    t('price_range', widget.lang),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPriceSlider(),
                  const SizedBox(height: 24),
                  
                  // Language Toggle
                  _buildLanguageButton(),
                  
                  const SizedBox(height: 20),
                  
                  // Subscription Card
                  _buildSubscriptionCard(),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerLink(String title, String id, {required bool isActive, required VoidCallback onTap}) {
    final isHovered = _hoveredLink == id;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredLink = id),
      onExit: (_) => setState(() => _hoveredLink = ''),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: (isHovered || isActive) 
                ? AppColors.teal.withOpacity(0.08) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              if (isActive)
                Container(
                  width: 3,
                  height: 18,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: (isHovered || isActive) ? FontWeight.w700 : FontWeight.w500,
                    color: (isHovered || isActive) ? AppColors.teal : Colors.black87,
                  ),
                  child: Text(title),
                ),
              ),
              if (isHovered || isActive)
                Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.teal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgePills() {
    const ages = ['age_3_5', 'age_6_8', 'age_9_12', 'age_teens'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ages.map((age) {
        final isSelected = _selectedAge == age;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAge = isSelected ? null : age;
            });
            _notifyFiltersChanged();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.teal : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.teal : Colors.black12,
                width: 1.2,
              ),
            ),
            child: Text(
              t(age, widget.lang),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLearningGoals() {
    return Column(
      children: _goals.keys.map((key) {
        final checked = _goals[key]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _goals[key] = !checked;
              });
              _notifyFiltersChanged();
            },
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: checked ? AppColors.teal : Colors.white,
                    border: Border.all(
                      color: checked ? AppColors.teal : Colors.black26,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: checked
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t(key, widget.lang),
                    style: TextStyle(
                      fontSize: 13,
                      color: checked ? Colors.black87 : Colors.black54,
                      fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.teal,
            inactiveTrackColor: Colors.grey.withOpacity(0.2),
            thumbColor: AppColors.teal,
            overlayColor: AppColors.teal.withOpacity(0.15),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            trackHeight: 3,
          ),
          child: Slider(
            value: _maxPrice,
            min: 20,
            max: 200,
            onChanged: (v) {
              setState(() => _maxPrice = v);
              _notifyFiltersChanged();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('\$20', style: TextStyle(fontSize: 11, color: Colors.black54)),
              Text(
                '\$${_maxPrice.round()}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageButton() {
    return GestureDetector(
      onTap: () {
        widget.onToggleLang();
        setState(() {});
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.teal.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.teal.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? 'العربية' : 'English',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isAr ? 'EN' : 'AR',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            t('member_benefit', widget.lang),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t('subscription_title', widget.lang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text(t('subscription_title', widget.lang)),
                  content: Text(isAr ? 'احصل على خصم 15% عند الاشتراك' : 'Get 15% off with subscription'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(isAr ? 'إلغاء' : 'Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
                      onPressed: () => Navigator.pop(context),
                      child: Text(isAr ? 'اشترك' : 'Subscribe'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white38),
              ),
              child: Text(
                t('learn_more', widget.lang),
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Navbar with Mobile Search Bar and Icons ──────────────────────────────────
class _CatalogNavbar extends StatefulWidget {
  final ScrollController scrollController;
  final String lang;
  final bool isDesktop;
  final VoidCallback onToggleLang;
  final void Function(String route) onNavigate;
  final VoidCallback onNavigateHome;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;

  const _CatalogNavbar({
    required this.scrollController,
    required this.lang,
    required this.isDesktop,
    required this.onToggleLang,
    required this.onNavigate,
    required this.onNavigateHome,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  State<_CatalogNavbar> createState() => _CatalogNavbarState();
}

class _CatalogNavbarState extends State<_CatalogNavbar> {
  late final TextEditingController _textController;
  String _hoveredLink = '';

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.searchQuery);
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final newText = _textController.text;
    if (newText != widget.searchQuery) {
      widget.onSearchChanged(newText);
    }
  }

  @override
  void didUpdateWidget(covariant _CatalogNavbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _textController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get isAr => widget.lang == 'ar';

  void _scrollToTop() => widget.scrollController.animateTo(
    0,
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeInOut,
  );

  Widget _logo() => GestureDetector(
    onTap: () {
      _scrollToTop();
      widget.onNavigateHome();
    },
    child: Image.asset('assets/images/logo.png', height: 44, fit: BoxFit.contain),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: widget.isDesktop ? _desktop(context) : _mobile(context),
    );
  }

  Widget _desktop(BuildContext context) {
    return Row(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      children: [
        _logo(),
        const SizedBox(width: 32),
        _navLink('Home', 'home', onTap: () => widget.onNavigateHome()),
        _navLink('Kits', 'kits', active: true, onTap: () => widget.onNavigate('kits')),
        _navLink('Subjects', 'subjects', onTap: () => widget.onNavigate('subjects')),
        _navLink('Educators', 'educators', onTap: () => widget.onNavigate('educators')),
        _navLink('Our Story', 'story', onTap: () => widget.onNavigate('story')),
        _navLink('Blog', 'blog', onTap: () => widget.onNavigate('blog')),
        const Spacer(),
        
        Container(
          width: 280,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(24),
            border: widget.searchQuery.isNotEmpty
                ? Border.all(color: AppColors.teal, width: 1.5)
                : null,
          ),
          child: TextField(
            controller: _textController,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            autofocus: false,
            enableInteractiveSelection: false,
            cursorColor: AppColors.teal,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            decoration: InputDecoration(
              hintText: isAr ? 'استكشف مغامرات التعلم...' : 'Explore learning adventures...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey[500]),
              suffixIcon: widget.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, size: 16, color: Colors.grey[500]),
                      onPressed: () {
                        _textController.clear();
                        widget.onClearSearch();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
        
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, size: 22),
          onPressed: () => widget.onNavigate('cart'),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, size: 22),
          onPressed: () => widget.onNavigate('account'),
        ),
        const SizedBox(width: 8),
        _langBtn(),
      ],
    );
  }

  // 🔥 MOBILE NAVBAR - with Search Bar, Cart, Profile, and Menu
  Widget _mobile(BuildContext context) {
    final isSearchActive = widget.searchQuery.isNotEmpty;
    
    return Column(
      children: [
        // First Row: Logo + Language + Cart + Profile + Menu
        Row(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _logo(),
            Row(
              children: [
                // Language Button
                _langBtn(),
                const SizedBox(width: 8),
                // Shopping Cart
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, size: 22),
                  onPressed: () => widget.onNavigate('cart'),
                ),
                const SizedBox(width: 4),
                // Profile Icon
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined, size: 22),
                  onPressed: () => widget.onNavigate('account'),
                ),
                const SizedBox(width: 4),
                // Menu Button
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Second Row: Search Bar (Full Width)
        Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(28),
            border: isSearchActive
                ? Border.all(color: AppColors.teal, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.search, size: 20, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _textController,
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  autofocus: false,
                  enableInteractiveSelection: false,
                  cursorColor: AppColors.teal,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: isAr ? 'استكشف مغامرات التعلم...' : 'Explore learning adventures...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
              if (isSearchActive)
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: Colors.grey[500]),
                  onPressed: () {
                    _textController.clear();
                    widget.onClearSearch();
                  },
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _navLink(String label, String id, {bool active = false, required VoidCallback onTap}) {
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
            fontWeight: isHovered || active ? FontWeight.w700 : FontWeight.w400,
            color: isHovered || active ? AppColors.teal : Colors.black87,
            decoration: isHovered || active ? TextDecoration.underline : TextDecoration.none,
            decorationColor: AppColors.teal,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _langBtn() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onToggleLang,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.teal.withOpacity(0.3)),
          ),
          child: Text(
            isAr ? 'EN' : 'AR',
            style: const TextStyle(color: AppColors.teal, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}