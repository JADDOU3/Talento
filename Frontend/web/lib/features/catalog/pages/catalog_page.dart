// // lib/features/catalog/pages/catalog_page.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../cubits/kit/kit_cubit.dart';
// import '../../../shared/models/kit_model.dart';
// import '../../../shared/components/footer/footer.dart';
// import '../../../shared/components/sections/catalog_sidebar.dart';
// import '../../../shared/i18n/catalog_translations.dart';
// import '../../../util/theme/app_colors.dart';
// import '../../../shared/components/navbar/navbar.dart';
// import '../../../shared/services/auth_state.dart';
// import '../../../shared/services/api_service.dart';
//
// // ============================================================================
// // Main Catalog Page
// // ============================================================================
//
// class CatalogPage extends StatefulWidget {
//   const CatalogPage({super.key});
//
//   @override
//   State<CatalogPage> createState() => _CatalogPageState();
// }
//
// class _CatalogPageState extends State<CatalogPage> with SingleTickerProviderStateMixin {
//   final ScrollController _scrollController = ScrollController();
//   late AnimationController _floatController;
//   late Animation<double> _floatAnimation;
//   String _lang = 'en';
//   Set<String> _favorites = {};
//   String _sortBy = 'default';
//   int _emojiIndex = 0;
//   bool _isLoadingFavorites = false;
//
//   CatalogFilters _uiFilters = const CatalogFilters(
//     selectedAge: null,
//     selectedGoals: {},
//     maxPrice: 200,
//   );
//
//   String? _activeFilterType;
//
//   bool get isAr => _lang == 'ar';
//   TextDirection get _dir => isAr ? TextDirection.rtl : TextDirection.ltr;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFavorites();
//     context.read<KitCubit>().getAllKits(page: 0);
//     _scrollController.addListener(_onScroll);
//
//     _floatController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )..repeat(reverse: true);
//     _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
//       CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
//     );
//
//     Future.doWhile(() async {
//       await Future.delayed(const Duration(seconds: 2));
//       if (mounted) {
//         setState(() {
//           _emojiIndex = (_emojiIndex + 1) % 8;
//         });
//         return true;
//       }
//       return false;
//     });
//   }
//
//   Future<void> _loadFavorites() async {
//     if (!AuthState.instance.isLoggedIn) return;
//
//     setState(() => _isLoadingFavorites = true);
//     try {
//       final result = await ApiService.getWithStatus('/favorites/');
//       if (result.isSuccess && result.body is List) {
//         final List<dynamic> favorites = result.body as List;
//         setState(() {
//           _favorites = favorites
//               .map((e) => (e as Map<String, dynamic>)['kitId'].toString())
//               .toSet();
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading favorites: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isLoadingFavorites = false);
//       }
//     }
//   }
//
//   Future<void> _toggleFavorite(int kitId) async {
//     if (!AuthState.instance.isLoggedIn) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please login to add favorites'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }
//
//     final kitIdStr = kitId.toString();
//     final isFavorited = _favorites.contains(kitIdStr);
//
//     try {
//       if (isFavorited) {
//         // Remove favorite
//         final result = await ApiService.deleteWithStatus('/favorites/$kitId');
//         if (result.isSuccess) {
//           setState(() {
//             _favorites.remove(kitIdStr);
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Removed from favorites'),
//               duration: Duration(seconds: 1),
//             ),
//           );
//         }
//       } else {
//         // Add favorite
//         final result = await ApiService.postWithStatus('/favorites/', {'kitId': kitId});
//         if (result.isSuccess) {
//           setState(() {
//             _favorites.add(kitIdStr);
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Added to favorites ❤️'),
//               duration: Duration(seconds: 1),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       final state = context.read<KitCubit>().state;
//       if (state is KitLoaded && state.hasMore) {
//         context.read<KitCubit>().loadNextPage();
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     _floatController.dispose();
//     super.dispose();
//   }
//
//   void _onTypeSelected(String type) {
//     setState(() => _activeFilterType = 'type');
//     context.read<KitCubit>().getKitsByType(type);
//   }
//
//   void _onMindsetSelected(int mindsetId) {
//     setState(() => _activeFilterType = 'mindset');
//     context.read<KitCubit>().getKitsByMindset(mindsetId);
//   }
//
//   void _onClearFilters() {
//     setState(() => _activeFilterType = null);
//     context.read<KitCubit>().getAllKits(page: 0);
//   }
//
//   void _onSearchChanged(String keyword) {
//     setState(() => _activeFilterType = keyword.isEmpty ? null : 'search');
//     context.read<KitCubit>().searchKitsDebounced(keyword);
//   }
//
//   void _clearSearch() {
//     setState(() => _activeFilterType = null);
//     context.read<KitCubit>().getAllKits(page: 0);
//   }
//
//   void _onFiltersChanged(CatalogFilters filters) {
//     setState(() {
//       _uiFilters = filters;
//     });
//   }
//
//   void _navigateToHome() => Navigator.pushReplacementNamed(context, '/');
//
//   void _navigateTo(String route) {
//     if (route == 'home') {
//       _navigateToHome();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Navigate to: $route'),
//           duration: const Duration(seconds: 1),
//         ),
//       );
//     }
//   }
//
//
//   // lib/features/catalog/pages/catalog_page.dart
// // Replace the _applyClientFilters method:
//
//   List<KitModel> _applyClientFilters(List<KitModel> kits) {
//     var list = kits.where((kit) {
//       // Price filter
//       if (kit.price > _uiFilters.maxPrice) return false;
//
//       // ✅ Age filter - check if kit matches selected age range
//       if (_uiFilters.selectedAge != null) {
//         final ageRange = _uiFilters.selectedAge!;
//         if (!_isKitInAgeRange(kit, ageRange)) {
//           return false;
//         }
//       }
//
//       return true;
//     }).toList();
//
//     // Sort by newest
//     if (_sortBy == 'newest') {
//       list.sort((a, b) {
//         if (a.isNew && !b.isNew) return -1;
//         if (!a.isNew && b.isNew) return 1;
//         return 0;
//       });
//     } else if (_sortBy == 'favorites') {
//       list = list.where((k) => _favorites.contains(k.id.toString())).toList();
//     }
//
//     return list;
//   }
//
//   bool _isKitInAgeRange(KitModel kit, String ageRange) {
//     switch (ageRange) {
//       case 'age_3_5':
//         return kit.age >= 3 && kit.age <= 5;
//       case 'age_6_7':
//         return kit.age >= 6 && kit.age <= 7;
//       default:
//         return true;
//     }
//   }
//
// // lib/features/catalog/pages/catalog_page.dart
// // Add this method after _applyClientFilters:
//
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final isDesktop = w >= 1024;
//     final isTablet = w >= 640 && w < 1024;
//
//     return Directionality(
//       textDirection: _dir,
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         endDrawer: isDesktop
//             ? null
//             : Drawer(
//           child: SafeArea(
//             child: _MobileDrawer(
//               lang: _lang,
//               filters: _uiFilters,
//               onFiltersChanged: _onFiltersChanged,
//               onNavigate: _navigateTo,
//               onNavigateHome: _navigateToHome,
//               onToggleLang: () =>
//                   setState(() => _lang = isAr ? 'en' : 'ar'),
//               onTypeSelected: _onTypeSelected,
//               onMindsetSelected: _onMindsetSelected,
//               onClearFilters: _onClearFilters,
//             ),
//           ),
//         ),
//         body: Stack(
//           children: [
//             SingleChildScrollView(
//               controller: _scrollController,
//               physics: const BouncingScrollPhysics(),
//               child: Column(
//                 children: [
//                   _HeroSection(
//                     lang: _lang,
//                     floatAnimation: _floatAnimation,
//                     emojiIndex: _emojiIndex,
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isDesktop ? 48 : 20,
//                       vertical: 32,
//                     ),
//                     child: isDesktop
//                         ? Row(
//                       textDirection: _dir,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         CatalogSidebar(
//                           lang: _lang,
//                           onFiltersChanged: _onFiltersChanged,
//                         ),
//                         const SizedBox(width: 40),
//                         Expanded(
//                           child: _buildContent(
//                               isTablet: isTablet, isDesktop: isDesktop),
//                         ),
//                       ],
//                     )
//                         : _buildContent(
//                         isTablet: isTablet, isDesktop: isDesktop),
//                   ),
//                   _NewsletterSection(
//                     lang: _lang,
//                     floatAnimation: _floatAnimation,
//                   ),
//                   Footer(scrollController: _scrollController),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: Navbar(
//                 scrollController: _scrollController,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildContent({required bool isTablet, required bool isDesktop}) {
//     return BlocBuilder<KitCubit, KitState>(
//       builder: (context, state) {
//         return Column(
//           crossAxisAlignment:
//           isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           children: [
//             _buildHeader(state),
//             const SizedBox(height: 28),
//             _buildBody(state, isTablet: isTablet, isDesktop: isDesktop),
//             const SizedBox(height: 20),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildHeader(KitState state) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20),
//       child: Row(
//         textDirection: _dir,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//               isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       t('catalog_title', _lang),
//                       style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.teal,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     TweenAnimationBuilder(
//                       tween: Tween<double>(begin: 0, end: 360),
//                       duration: const Duration(seconds: 4),
//                       builder: (context, value, child) {
//                         return Transform.rotate(
//                           angle: value * 3.14159 / 180,
//                           child: child,
//                         );
//                       },
//                       child: const Text('🎯', style: TextStyle(fontSize: 24)),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   t('catalog_subtitle', _lang),
//                   style: const TextStyle(
//                       color: Colors.grey, fontSize: 13, height: 1.5),
//                   textAlign: isAr ? TextAlign.right : TextAlign.left,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.black12),
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.white,
//             ),
//             child: DropdownButton<String>(
//               value: _sortBy,
//               underline: const SizedBox(),
//               icon: const Icon(Icons.keyboard_arrow_down, size: 18),
//               style: const TextStyle(fontSize: 13, color: Colors.black87),
//               borderRadius: BorderRadius.circular(12),
//               items: [
//                 DropdownMenuItem(
//                     value: 'default',
//                     child: Text(isAr ? 'الافتراضي' : 'Default')),
//                 DropdownMenuItem(
//                     value: 'newest',
//                     child: Text(isAr ? 'أحدث الوصولات' : 'Newest Arrivals')),
//                 DropdownMenuItem(
//                     value: 'favorites',
//                     child: Text(isAr ? 'المفضلات' : 'Favorites')),
//               ],
//               onChanged: (value) =>
//                   setState(() => _sortBy = value ?? 'default'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBody(KitState state,
//       {required bool isTablet, required bool isDesktop}) {
//     if (state is KitLoading) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 80),
//           child: CircularProgressIndicator(color: AppColors.teal),
//         ),
//       );
//     }
//
//     if (state is KitError) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 60),
//           child: Column(
//             children: [
//               Icon(
//                 state.message == 'Unauthorized'
//                     ? Icons.lock_outline
//                     : Icons.error_outline,
//                 size: 64,
//                 color: Colors.grey[300],
//               ),
//               const SizedBox(height: 16),
//               Text(state.message,
//                   style: TextStyle(fontSize: 15, color: Colors.grey[600])),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.teal,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30)),
//                 ),
//                 onPressed: () =>
//                     context.read<KitCubit>().getAllKits(page: 0),
//                 child: const Text('Retry',
//                     style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     if (state is KitLoaded || state is KitLoadingMore) {
//       final kits = state is KitLoaded
//           ? state.kits
//           : (state as KitLoadingMore).currentKits;
//
//       final filtered = _applyClientFilters(kits);
//
//       if (filtered.isEmpty) {
//         return _EmptyState();
//       }
//
//       return Column(
//         children: [
//           _buildGrid(filtered, isTablet: isTablet, isDesktop: isDesktop),
//           if (state is KitLoadingMore)
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 24),
//               child: CircularProgressIndicator(color: AppColors.teal),
//             ),
//         ],
//       );
//     }
//
//     return const SizedBox.shrink();
//   }
//
//   Widget _EmptyState() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 80),
//       child: Column(
//         children: [
//           const Text('🔍', style: TextStyle(fontSize: 64)),
//           const SizedBox(height: 16),
//           Text(
//             isAr
//                 ? 'لا توجد نتائج تطابق الفلاتر المختارة'
//                 : 'No kits match your selected filters',
//             style: TextStyle(color: Colors.grey[500], fontSize: 15),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             isAr ? 'جرب تغيير الفلاتر' : 'Try changing your filters',
//             style: TextStyle(color: Colors.grey[400], fontSize: 13),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGrid(List<KitModel> kits,
//       {required bool isTablet, required bool isDesktop}) {
//     final cols = isDesktop ? 3 : (isTablet ? 2 : 1);
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: cols,
//         crossAxisSpacing: 20,
//         mainAxisSpacing: 20,
//         childAspectRatio: 0.65,
//       ),
//       itemCount: kits.length,
//       itemBuilder: (_, i) {
//         final k = kits[i];
//         final favKey = k.id.toString();
//         return _KitCard(
//           kit: k,
//           lang: _lang,
//           isFav: _favorites.contains(favKey),
//           onFavToggle: () => _toggleFavorite(k.id),
//           onTap: () => Navigator.pushNamed(
//             context,
//             '/kit-details',
//             arguments: k.id,
//           ),
//           floatAnimation: _floatAnimation,
//           index: i,
//         );
//       },
//     );
//   }
// }
//
// // ─── Hero Section ─────────────────────────────────────────────────────────────
// class _HeroSection extends StatelessWidget {
//   final String lang;
//   final Animation<double> floatAnimation;
//   final int emojiIndex;
//
//   const _HeroSection({
//     required this.lang,
//     required this.floatAnimation,
//     required this.emojiIndex,
//   });
//
//   bool get isAr => lang == 'ar';
//
//   @override
//   Widget build(BuildContext context) {
//     const emojis = ['🚀', '🌟', '🌈', '🎯', '💡', '⭐', '🎨', '📚'];
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.teal,
//             AppColors.teal.withOpacity(0.7),
//             const Color(0xFF3FA796),
//           ],
//         ),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             top: 30,
//             right: 20,
//             child: _FloatingEmoji('⭐', floatAnimation, delay: 20),
//           ),
//           Positioned(
//             bottom: 10,
//             left: 20,
//             child: _FloatingEmoji('🌈', floatAnimation, delay: 50),
//           ),
//           Positioned(
//             top: 70,
//             left: 50,
//             child: _FloatingEmoji('🎯', floatAnimation, delay: 80),
//           ),
//           Positioned(
//             bottom: 50,
//             right: 50,
//             child: _FloatingEmoji('💡', floatAnimation, delay: 30),
//           ),
//           Center(
//             child: Column(
//               children: [
//                 TweenAnimationBuilder(
//                   tween: Tween<double>(begin: 0, end: 1),
//                   duration: const Duration(milliseconds: 800),
//                   curve: Curves.elasticOut,
//                   builder: (context, value, child) {
//                     return Transform.translate(
//                       offset: Offset(20 * (1 - value), 0),
//                       child: Opacity(
//                         opacity: value.clamp(0.0, 1.0),
//                         child: child,
//                       ),
//                     );
//                   },
//                   child: Text(
//                     emojis[emojiIndex % emojis.length],
//                     style: const TextStyle(fontSize: 40),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   isAr ? 'اكتشف مغامرات التعلم' : 'Discover Learning Adventures',
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   isAr
//                       ? 'اختر من بين مجموعاتنا المتنوعة من الأنشطة التعليمية'
//                       : 'Choose from our diverse collection of educational kits',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.85),
//                     fontSize: 14,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _FloatingEmoji extends StatelessWidget {
//   final String emoji;
//   final Animation<double> floatAnimation;
//   final double delay;
//
//   const _FloatingEmoji(
//       this.emoji,
//       this.floatAnimation, {
//         this.delay = 0,
//       });
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: floatAnimation,
//       builder: (context, child) {
//         final double rawValue = (floatAnimation.value + delay) % 1.0;
//         final double clampedValue = rawValue.clamp(0.0, 1.0);
//         final double offset = 10 * clampedValue;
//         final double opacity = (0.6 + 0.4 * (1 - clampedValue)).clamp(0.0, 1.0);
//
//         return Transform.translate(
//           offset: Offset(0, -offset),
//           child: Opacity(
//             opacity: opacity,
//             child: child,
//           ),
//         );
//       },
//       child: Text(emoji, style: const TextStyle(fontSize: 28)),
//     );
//   }
// }
//
// // ─── Newsletter Section ──────────────────────────────────────────────────────
// class _NewsletterSection extends StatelessWidget {
//   final String lang;
//   final Animation<double> floatAnimation;
//
//   const _NewsletterSection({
//     required this.lang,
//     required this.floatAnimation,
//   });
//
//   bool get isAr => lang == 'ar';
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.teal.withOpacity(0.08),
//             AppColors.teal.withOpacity(0.02),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//           color: AppColors.teal.withOpacity(0.15),
//           width: 2,
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Text('📬', style: TextStyle(fontSize: 24)),
//                     const SizedBox(width: 10),
//                     Text(
//                       isAr ? 'اشترك في النشرة البريدية' : 'Subscribe to Newsletter',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.teal,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   isAr
//                       ? 'احصل على أحدث المجموعات والعروض الحصرية'
//                       : 'Get the latest kits and exclusive offers',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           AnimatedBuilder(
//             animation: floatAnimation,
//             builder: (context, child) {
//               return Transform.translate(
//                 offset: Offset(5 * floatAnimation.value, 0),
//                 child: child,
//               );
//             },
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.teal,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Subscribed! 🎉'),
//                     duration: Duration(seconds: 2),
//                     backgroundColor: AppColors.teal,
//                   ),
//                 );
//               },
//               child: Text(
//                 isAr ? 'اشترك الآن' : 'Subscribe Now',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Kit Card ─────────────────────────────────────────────────────────────────
// class _KitCard extends StatefulWidget {
//   final KitModel kit;
//   final String lang;
//   final bool isFav;
//   final VoidCallback onFavToggle;
//   final VoidCallback onTap;
//   final Animation<double> floatAnimation;
//   final int index;
//
//   const _KitCard({
//     required this.kit,
//     required this.lang,
//     required this.isFav,
//     required this.onFavToggle,
//     required this.onTap,
//     required this.floatAnimation,
//     required this.index,
//   });
//
//   @override
//   State<_KitCard> createState() => _KitCardState();
// }
//
// class _KitCardState extends State<_KitCard> with SingleTickerProviderStateMixin {
//   bool _hovering = false;
//   late AnimationController _rotationController;
//   late Animation<double> _rotationAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _rotationController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )..repeat(reverse: true);
//     _rotationAnimation = Tween<double>(begin: -3, end: 3).animate(
//       CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _rotationController.dispose();
//     super.dispose();
//   }
//
//   bool get isAr => widget.lang == 'ar';
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: widget.floatAnimation,
//       builder: (context, child) {
//         final floatOffset = 3 * widget.floatAnimation.value * (widget.index % 2 == 0 ? 1 : 0.7);
//         return Transform.translate(
//           offset: Offset(0, -floatOffset),
//           child: child,
//         );
//       },
//       child: MouseRegion(
//         onEnter: (_) => setState(() => _hovering = true),
//         onExit: (_) => setState(() => _hovering = false),
//         cursor: SystemMouseCursors.click,
//         child: GestureDetector(
//           onTap: widget.onTap,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             transform: _hovering
//                 ? (Matrix4.identity()..translate(0.0, -8.0))
//                 : Matrix4.identity(),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(28),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(_hovering ? 0.12 : 0.05),
//                   blurRadius: _hovering ? 24 : 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(28)),
//                         child: widget.kit.imageURL.isNotEmpty
//                             ? Image.network(
//                           widget.kit.imageURL,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) =>
//                               _imagePlaceholder(),
//                           loadingBuilder: (_, child, progress) {
//                             if (progress == null) return child;
//                             return _imageLoading();
//                           },
//                         )
//                             : _imagePlaceholder(),
//                       ),
//                       if (widget.kit.isNew)
//                         Positioned(
//                           top: 12,
//                           right: isAr ? null : 12,
//                           left: isAr ? 12 : null,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFFF4D6D),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Text('✨', style: TextStyle(fontSize: 10)),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   t('new_arrival', widget.lang),
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       Positioned(
//                         bottom: 12,
//                         right: isAr ? null : 12,
//                         left: isAr ? 12 : null,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 8,
//                               ),
//                             ],
//                           ),
//                           child: Text(
//                             '\$${widget.kit.price.toStringAsFixed(2)}',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.teal,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(14),
//                     child: Column(
//                       crossAxisAlignment: isAr
//                           ? CrossAxisAlignment.end
//                           : CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.kit.name,
//                           style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               height: 1.3),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           textAlign: isAr ? TextAlign.right : TextAlign.left,
//                         ),
//                         const SizedBox(height: 4),
//                         Expanded(
//                           child: Text(
//                             widget.kit.description,
//                             style: const TextStyle(
//                                 color: Colors.grey, fontSize: 11),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             textAlign:
//                             isAr ? TextAlign.right : TextAlign.left,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           textDirection:
//                           isAr ? TextDirection.rtl : TextDirection.ltr,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Flexible(
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: AppColors.teal.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Text(
//                                   widget.kit.type,
//                                   style: const TextStyle(
//                                     color: AppColors.teal,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ),
//                             Text(
//                               '⭐ ${widget.kit.rating ?? 4.5}',
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           textDirection:
//                           isAr ? TextDirection.rtl : TextDirection.ltr,
//                           children: [
//                             Expanded(
//                               child: ElevatedButton.icon(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.teal,
//                                   foregroundColor: Colors.white,
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 9),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(30),
//                                   ),
//                                   elevation: 0,
//                                 ),
//                                 onPressed: () {
//                                   ScaffoldMessenger.of(context)
//                                       .showSnackBar(SnackBar(
//                                     content: Row(
//                                       children: [
//                                         const Text('🎉'),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                             '${t('add_to_cart', widget.lang)}: ${widget.kit.name}'),
//                                       ],
//                                     ),
//                                     duration: const Duration(seconds: 1),
//                                     backgroundColor: AppColors.teal,
//                                   ));
//                                 },
//                                 icon: const Icon(
//                                     Icons.shopping_cart_outlined,
//                                     size: 14),
//                                 label: Text(
//                                   t('add_to_cart', widget.lang),
//                                   style: const TextStyle(fontSize: 11),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             GestureDetector(
//                               onTap: widget.onFavToggle,
//                               child: AnimatedBuilder(
//                                 animation: _rotationAnimation,
//                                 builder: (context, child) {
//                                   return Transform.rotate(
//                                     angle: _rotationAnimation.value * 3.14159 / 180,
//                                     child: child,
//                                   );
//                                 },
//                                 child: AnimatedContainer(
//                                   duration: const Duration(milliseconds: 200),
//                                   width: 36,
//                                   height: 36,
//                                   decoration: BoxDecoration(
//                                     color: widget.isFav
//                                         ? const Color(0xFFFFE4E8)
//                                         : Colors.grey.withOpacity(0.08),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(
//                                     widget.isFav
//                                         ? Icons.favorite
//                                         : Icons.favorite_border,
//                                     size: 16,
//                                     color: widget.isFav
//                                         ? const Color(0xFFFF4D6D)
//                                         : Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _imagePlaceholder() => Container(
//     color: Colors.grey[200],
//     child: const Center(
//         child: Icon(Icons.image_not_supported,
//             size: 40, color: Colors.grey)),
//   );
//
//   Widget _imageLoading() => Container(
//     color: Colors.grey[100],
//     child: const Center(
//         child: CircularProgressIndicator(
//             color: AppColors.teal, strokeWidth: 2)),
//   );
// }
//
// // ─── Mobile Drawer ────────────────────────────────────────────────────────────
// class _MobileDrawer extends StatefulWidget {
//   final String lang;
//   final CatalogFilters filters;
//   final void Function(CatalogFilters) onFiltersChanged;
//   final void Function(String route) onNavigate;
//   final VoidCallback onNavigateHome;
//   final VoidCallback onToggleLang;
//   final void Function(String) onTypeSelected;
//   final void Function(int mindsetId) onMindsetSelected;
//   final VoidCallback onClearFilters;
//
//   const _MobileDrawer({
//     required this.lang,
//     required this.filters,
//     required this.onFiltersChanged,
//     required this.onNavigate,
//     required this.onNavigateHome,
//     required this.onToggleLang,
//     required this.onTypeSelected,
//     required this.onMindsetSelected,
//     required this.onClearFilters,
//   });
//
//   @override
//   State<_MobileDrawer> createState() => _MobileDrawerState();
// }
//
// class _MobileDrawerState extends State<_MobileDrawer> {
//   bool get isAr => widget.lang == 'ar';
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 300,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
//             decoration: BoxDecoration(
//               color: AppColors.teal.withOpacity(0.05),
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(20),
//                 bottomRight: Radius.circular(20),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Image.asset('assets/images/logo.png',
//                     height: 40, fit: BoxFit.contain),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Column(
//               children: [
//                 _link('Home',
//                     isActive: false,
//                     onTap: () {
//                       Navigator.pop(context);
//                       widget.onNavigateHome();
//                     }),
//                 _link('Kits',
//                     isActive: true,
//                     onTap: () {
//                       Navigator.pop(context);
//                       widget.onNavigate('kits');
//                     }),
//                 _link('Subjects',
//                     isActive: false,
//                     onTap: () {
//                       Navigator.pop(context);
//                       widget.onNavigate('subjects');
//                     }),
//                 _link('Educators',
//                     isActive: false,
//                     onTap: () {
//                       Navigator.pop(context);
//                       widget.onNavigate('educators');
//                     }),
//                 _link('Our Story',
//                     isActive: false,
//                     onTap: () {
//                       Navigator.pop(context);
//                       widget.onNavigate('story');
//                     }),
//                 _link('Blog',
//                     isActive: false,
//                     onTap: () {
//                       Navigator.pop(context);
//                       widget.onNavigate('blog');
//                     }),
//               ],
//             ),
//           ),
//           Divider(color: Colors.grey[200], height: 32),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: CatalogSidebar(
//                 lang: widget.lang,
//                 onFiltersChanged: widget.onFiltersChanged,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: GestureDetector(
//               onTap: () {
//                 widget.onToggleLang();
//                 setState(() {});
//               },
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                     vertical: 10, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: AppColors.teal.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(12),
//                   border:
//                   Border.all(color: AppColors.teal.withOpacity(0.2)),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       isAr ? 'العربية' : 'English',
//                       style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.teal),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: AppColors.teal,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Text(
//                         isAr ? 'EN' : 'AR',
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                             fontWeight: FontWeight.w700),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _link(String title,
//       {required bool isActive, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding:
//         const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//         margin: const EdgeInsets.only(bottom: 4),
//         decoration: BoxDecoration(
//           color: isActive
//               ? AppColors.teal.withOpacity(0.08)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             if (isActive) ...[
//               const Icon(Icons.check_circle, color: AppColors.teal, size: 16),
//               const SizedBox(width: 8),
//             ],
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//                 color: isActive ? AppColors.teal : Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// lib/features/catalog/pages/catalog_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/kit/kit_cubit.dart';
import '../../../shared/models/kit_model.dart';
import '../../../shared/components/footer/footer.dart';
import '../../../shared/components/sections/catalog_sidebar.dart';
import '../../../shared/i18n/catalog_translations.dart';
import '../../../util/theme/app_colors.dart';
import '../../../shared/components/navbar/navbar.dart';
import '../../../shared/services/auth_state.dart';
import '../../../shared/services/api_service.dart';

// ============================================================================
// Palette helper — keeps the catalog in the same accent family as the blog
// ============================================================================

const List<Color> _catalogAccents = [
  AppColors.cartForestGreen,
  AppColors.cartTeal,
  Color(0xFFDDA83A),
  Color(0xFFE07A5F),
  Color(0xFF3FA796),
];

Color _accentFor(int index) => _catalogAccents[index % _catalogAccents.length];

Widget _decorativeCircle(double size, Color color) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

// ============================================================================
// Main Catalog Page
// ============================================================================

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  String _lang = 'en';
  Set<String> _favorites = {};
  String _sortBy = 'default';
  int _emojiIndex = 0;
  bool _isLoadingFavorites = false;

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
    _loadFavorites();
    context.read<KitCubit>().getAllKits(page: 0);
    _scrollController.addListener(_onScroll);

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _emojiIndex = (_emojiIndex + 1) % 8;
        });
        return true;
      }
      return false;
    });
  }

  Future<void> _loadFavorites() async {
    if (!AuthState.instance.isLoggedIn) return;

    setState(() => _isLoadingFavorites = true);
    try {
      final result = await ApiService.getWithStatus('/favorites/');
      if (result.isSuccess && result.body is List) {
        final List<dynamic> favorites = result.body as List;
        setState(() {
          _favorites = favorites
              .map((e) => (e as Map<String, dynamic>)['kitId'].toString())
              .toSet();
        });
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingFavorites = false);
      }
    }
  }

  Future<void> _toggleFavorite(int kitId) async {
    if (!AuthState.instance.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login to add favorites'),
          backgroundColor: AppColors.cartForestGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final kitIdStr = kitId.toString();
    final isFavorited = _favorites.contains(kitIdStr);

    try {
      if (isFavorited) {
        final result = await ApiService.deleteWithStatus('/favorites/$kitId');
        if (result.isSuccess) {
          setState(() {
            _favorites.remove(kitIdStr);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Removed from favorites'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        final result = await ApiService.postWithStatus('/favorites/', {'kitId': kitId});
        if (result.isSuccess) {
          setState(() {
            _favorites.add(kitIdStr);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Added to favorites ❤️'),
              duration: const Duration(seconds: 1),
              backgroundColor: AppColors.cartTeal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
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
    _floatController.dispose();
    super.dispose();
  }

  void _onTypeSelected(String type) {
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

  void _onFiltersChanged(CatalogFilters filters) {
    setState(() {
      _uiFilters = filters;
    });
  }

  void _navigateToHome() => Navigator.pushReplacementNamed(context, '/');

  void _navigateTo(String route) {
    if (route == 'home') {
      _navigateToHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigate to: $route'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  List<KitModel> _applyClientFilters(List<KitModel> kits) {
    var list = kits.where((kit) {
      if (kit.price > _uiFilters.maxPrice) return false;

      if (_uiFilters.selectedAge != null) {
        final ageRange = _uiFilters.selectedAge!;
        if (!_isKitInAgeRange(kit, ageRange)) {
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
      list = list.where((k) => _favorites.contains(k.id.toString())).toList();
    }

    return list;
  }

  bool _isKitInAgeRange(KitModel kit, String ageRange) {
    switch (ageRange) {
      case 'age_3_5':
        return kit.age >= 3 && kit.age <= 5;
      case 'age_6_7':
        return kit.age >= 6 && kit.age <= 7;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 1024;
    final isTablet = w >= 640 && w < 1024;

    return Directionality(
      textDirection: _dir,
      child: Scaffold(
        backgroundColor: AppColors.cartPageBackground,
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
              onMindsetSelected: _onMindsetSelected,
              onClearFilters: _onClearFilters,
            ),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _HeroSection(
                    lang: _lang,
                    floatAnimation: _floatAnimation,
                    emojiIndex: _emojiIndex,
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
                  _NewsletterSection(
                    lang: _lang,
                    floatAnimation: _floatAnimation,
                  ),
                  Footer(scrollController: _scrollController),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Navbar(
                scrollController: _scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildHeader(KitState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        textDirection: _dir,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 26,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.cartTeal, Color(0xFFDDA83A)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      t('catalog_title', _lang),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.cartForestGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 360),
                      duration: const Duration(seconds: 4),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: value * 3.14159 / 180,
                          child: child,
                        );
                      },
                      child: const Text('🎯', style: TextStyle(fontSize: 22)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    t('catalog_subtitle', _lang),
                    style: TextStyle(
                      color: AppColors.cartMutedGrey.withValues(alpha: 0.85),
                      fontSize: 13,
                      height: 1.5,
                    ),
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cartTeal.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.cartTeal.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _sortBy,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: AppColors.cartTeal),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.cartForestGreen,
                fontWeight: FontWeight.w600,
              ),
              borderRadius: BorderRadius.circular(14),
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
      ),
    );
  }

  Widget _buildBody(KitState state,
      {required bool isTablet, required bool isDesktop}) {
    if (state is KitLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: CircularProgressIndicator(color: AppColors.cartTeal),
        ),
      );
    }

    if (state is KitError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.cartTeal.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  state.message == 'Unauthorized'
                      ? Icons.lock_outline
                      : Icons.error_outline,
                  size: 40,
                  color: AppColors.cartTeal.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 18),
              Text(state.message,
                  style: TextStyle(
                      fontSize: 15,
                      color: AppColors.cartMutedGrey.withValues(alpha: 0.9))),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cartTeal,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () =>
                    context.read<KitCubit>().getAllKits(page: 0),
                child: const Text('Retry',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
        return _buildEmptyState();
      }

      return Column(
        children: [
          _buildGrid(filtered, isTablet: isTablet, isDesktop: isDesktop),
          if (state is KitLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: AppColors.cartTeal),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cartTeal.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.cartTeal.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('🔍', style: TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: 18),
          Text(
            isAr
                ? 'لا توجد نتائج تطابق الفلاتر المختارة'
                : 'No kits match your selected filters',
            style: TextStyle(
                color: AppColors.cartMutedGrey.withValues(alpha: 0.9), fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            isAr ? 'جرب تغيير الفلاتر' : 'Try changing your filters',
            style: TextStyle(
                color: AppColors.cartMutedGrey.withValues(alpha: 0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }

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
        childAspectRatio: 0.65,
      ),
      itemCount: kits.length,
      itemBuilder: (_, i) {
        final k = kits[i];
        final favKey = k.id.toString();
        return _KitCard(
          kit: k,
          lang: _lang,
          isFav: _favorites.contains(favKey),
          onFavToggle: () => _toggleFavorite(k.id),
          onTap: () => Navigator.pushNamed(
            context,
            '/kit-details',
            arguments: k.id,
          ),
          floatAnimation: _floatAnimation,
          index: i,
        );
      },
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final String lang;
  final Animation<double> floatAnimation;
  final int emojiIndex;

  const _HeroSection({
    required this.lang,
    required this.floatAnimation,
    required this.emojiIndex,
  });

  bool get isAr => lang == 'ar';

  @override
  Widget build(BuildContext context) {
    const emojis = ['🚀', '🌟', '🎯', '💡', '⭐', '🎨', '📚'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 56),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cartForestGreen,
            AppColors.cartTeal,
            Color(0xFF3FA796),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20,
            right: -10,
            child: _decorativeCircle(70, const Color(0xFFE07A5F).withValues(alpha: 0.35)),
          ),
          Positioned(
            top: 40,
            right: 60,
            child: _decorativeCircle(24, const Color(0xFFDDA83A).withValues(alpha: 0.55)),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: _decorativeCircle(90, Colors.white.withValues(alpha: 0.14)),
          ),
          Positioned(
            bottom: 20,
            left: 100,
            child: _decorativeCircle(18, const Color(0xFFE07A5F).withValues(alpha: 0.5)),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: _FloatingEmoji('', floatAnimation, delay: 20),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            child: _FloatingEmoji('', floatAnimation, delay: 50),
          ),
          Positioned(
            top: 70,
            left: 50,
            child: _FloatingEmoji('', floatAnimation, delay: 80),
          ),
          Positioned(
            bottom: 50,
            right: 50,
            child: _FloatingEmoji('', floatAnimation, delay: 30),
          ),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDA83A).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAr ? 'الكتالوج' : 'CATALOG',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    emojis[emojiIndex % emojis.length],
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isAr ? 'اكتشف مغامرات التعلم' : 'Discover Learning Adventures',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  isAr
                      ? 'اختر من بين مجموعاتنا المتنوعة من الأنشطة التعليمية'
                      : 'Choose from our diverse collection of educational kits',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingEmoji extends StatelessWidget {
  final String emoji;
  final Animation<double> floatAnimation;
  final double delay;

  const _FloatingEmoji(
      this.emoji,
      this.floatAnimation, {
        this.delay = 0,
      });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatAnimation,
      builder: (context, child) {
        final double rawValue = (floatAnimation.value + delay) % 1.0;
        final double clampedValue = rawValue.clamp(0.0, 1.0);
        final double offset = 10 * clampedValue;
        final double opacity = (0.6 + 0.4 * (1 - clampedValue)).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, -offset),
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }
}

// ─── Newsletter Section ──────────────────────────────────────────────────────
class _NewsletterSection extends StatelessWidget {
  final String lang;
  final Animation<double> floatAnimation;

  const _NewsletterSection({
    required this.lang,
    required this.floatAnimation,
  });

  bool get isAr => lang == 'ar';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      padding: const EdgeInsets.all(28),
      constraints: const BoxConstraints(maxWidth: 1180),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cartForestGreen.withValues(alpha: 0.08),
            AppColors.cartTeal.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.cartTeal.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📬', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Text(
                      isAr ? 'اشترك في النشرة البريدية' : 'Subscribe to Newsletter',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cartForestGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isAr
                      ? 'احصل على أحدث المجموعات والعروض الحصرية'
                      : 'Get the latest kits and exclusive offers',
                  style: TextStyle(
                    color: AppColors.cartMutedGrey.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          AnimatedBuilder(
            animation: floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(5 * floatAnimation.value / 10, 0),
                child: child,
              );
            },
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cartTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Subscribed! 🎉'),
                    duration: const Duration(seconds: 6),
                    backgroundColor: AppColors.cartTeal,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Text(
                isAr ? 'اشترك الآن' : 'Subscribe Now',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
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
  final Animation<double> floatAnimation;
  final int index;

  const _KitCard({
    required this.kit,
    required this.lang,
    required this.isFav,
    required this.onFavToggle,
    required this.onTap,
    required this.floatAnimation,
    required this.index,
  });

  @override
  State<_KitCard> createState() => _KitCardState();
}

class _KitCardState extends State<_KitCard> with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 13),
      vsync: this,
    )..repeat(reverse: true);
    _rotationAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  bool get isAr => widget.lang == 'ar';

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(widget.index);

    return AnimatedBuilder(
      animation: widget.floatAnimation,
      builder: (context, child) {
        final floatOffset = 3 * widget.floatAnimation.value * (widget.index % 2 == 0 ? 1 : 0.7);
        return Transform.translate(
          offset: Offset(0, -floatOffset),
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: _hovering
                ? (Matrix4.identity()..translate(0.0, -8.0))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border(
                top: BorderSide(color: accent, width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: _hovering ? 0.22 : 0.1),
                  blurRadius: _hovering ? 26 : 14,
                  offset: const Offset(0, 6),
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
                            top: Radius.circular(24)),
                        child: widget.kit.imageURL.isNotEmpty
                            ? Image.network(
                          widget.kit.imageURL,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _imagePlaceholder(accent),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return _imageLoading(accent);
                          },
                        )
                            : _imagePlaceholder(accent),
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
                              color: const Color(0xFFE07A5F),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 10)),
                                const SizedBox(width: 4),
                                Text(
                                  t('new_arrival', widget.lang),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 12,
                        right: isAr ? null : 12,
                        left: isAr ? 12 : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            '\$${widget.kit.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: accent,
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
                              fontWeight: FontWeight.w800,
                              color: AppColors.cartForestGreen,
                              height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            widget.kit.description,
                            style: TextStyle(
                                color: AppColors.cartMutedGrey.withValues(alpha: 0.85),
                                fontSize: 11,
                                height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign:
                            isAr ? TextAlign.right : TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          textDirection:
                          isAr ? TextDirection.rtl : TextDirection.ltr,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: accent.withValues(alpha: 0.18),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.kit.type,
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Text(
                              '⭐ ${widget.kit.rating ?? 4.5}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.cartMutedGrey.withValues(alpha: 0.75),
                              ),
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
                                  backgroundColor: accent,
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
                                    content: Row(
                                      children: [
                                        const Text('🎉'),
                                        const SizedBox(width: 8),
                                        Text(
                                            '${t('add_to_cart', widget.lang)}: ${widget.kit.name}'),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: accent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ));
                                },
                                icon: const Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 14),
                                label: Text(
                                  t('add_to_cart', widget.lang),
                                  style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: widget.onFavToggle,
                              child: AnimatedBuilder(
                                animation: _rotationAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _rotationAnimation.value * 3.14159 / 180,
                                    child: child,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: widget.isFav
                                        ? const Color(0xFFFFE4E8)
                                        : AppColors.cartMutedGrey.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 16,
                                    color: widget.isFav
                                        ? const Color(0xFFE07A5F)
                                        : AppColors.cartMutedGrey,
                                  ),
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
      ),
    );
  }

  Widget _imagePlaceholder(Color accent) => Container(
    color: accent.withValues(alpha: 0.08),
    child: Center(
        child: Icon(Icons.image_not_supported,
            size: 36, color: accent.withValues(alpha: 0.4))),
  );

  Widget _imageLoading(Color accent) => Container(
    color: accent.withValues(alpha: 0.06),
    child: Center(
        child: CircularProgressIndicator(
            color: accent, strokeWidth: 2)),
  );
}

// ─── Mobile Drawer ────────────────────────────────────────────────────────────
class _MobileDrawer extends StatefulWidget {
  final String lang;
  final CatalogFilters filters;
  final void Function(CatalogFilters) onFiltersChanged;
  final void Function(String route) onNavigate;
  final VoidCallback onNavigateHome;
  final VoidCallback onToggleLang;
  final void Function(String) onTypeSelected;
  final void Function(int mindsetId) onMindsetSelected;
  final VoidCallback onClearFilters;

  const _MobileDrawer({
    required this.lang,
    required this.filters,
    required this.onFiltersChanged,
    required this.onNavigate,
    required this.onNavigateHome,
    required this.onToggleLang,
    required this.onTypeSelected,
    required this.onMindsetSelected,
    required this.onClearFilters,
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
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cartForestGreen,
                  AppColors.cartTeal,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/logo.png',
                    height: 36, fit: BoxFit.contain),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
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
          Divider(color: AppColors.cartMutedGrey.withValues(alpha: 0.15), height: 32),
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
                  color: AppColors.cartTeal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                  Border.all(color: AppColors.cartTeal.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? 'العربية' : 'English',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cartForestGreen),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cartTeal,
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
              ? AppColors.cartTeal.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (isActive) ...[
              const Icon(Icons.check_circle, color: AppColors.cartTeal, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.cartForestGreen : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}