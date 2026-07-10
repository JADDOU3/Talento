import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/kit/kit_cubit.dart';
import '../../cubits/kit/kit_state.dart';
import '../../models/kit/kit_enums.dart';
import '../../models/kit/kit_model.dart';
import '../../services/kit/kit_service.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/inside_item_tile.dart';

class KitDetailsScreen extends StatelessWidget {
  final int kitId;

  const KitDetailsScreen({
    super.key,
    required this.kitId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KitCubit(KitService())..getKitById(kitId),
      child: _KitDetailsView(kitId: kitId),
    );
  }
}

class _KitDetailsView extends StatefulWidget {
  final int kitId;

  const _KitDetailsView({
    required this.kitId,
  });

  @override
  State<_KitDetailsView> createState() => _KitDetailsViewState();
}

class _KitDetailsViewState extends State<_KitDetailsView> {
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                _buildDetailsTopBar(context),
                _buildScreenTitle(),
                Expanded(
                  child: BlocBuilder<KitCubit, KitState>(
                    builder: (context, state) {
                      if (state is KitLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is KitError) {
                        return _buildErrorState(context, state.message);
                      }

                      if (state is KitDetailsLoaded) {
                        final kit = state.kit;
                        final images = _kitCarouselImages(kit);
                        final activitiesCount = state.activitiesCount;

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildImageCarousel(
                                imageUrls: images,
                                rating: kit.rating,
                              ),
                              const SizedBox(height: 16),
                              _buildTitleAndDescription(kit),
                              const SizedBox(height: 16),
                              _buildInfoChips(
                                kit,
                                activitiesCount: activitiesCount,
                              ),
                              if (kit.kitItems.isNotEmpty) ...[
                                const SizedBox(height: 26),
                                _buildInsideSection(kit.kitItems),
                              ],
                              const SizedBox(height: 30),
                              _buildBottomButton(context, kit.id),
                              const SizedBox(height: 20),
                            ],
                          ),
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
      ),
    );
  }

  Widget _buildDetailsTopBar(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.92),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 13,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _detailsTopCircleButton(
                onPressed: () => Navigator.pop(context),
                icon: Icons.arrow_back_ios_rounded,
              ),
              const Spacer(),
              Image.asset(
                'assets/icons/logo1.png',
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Text(
                    'Talento',
                    style: TextStyle(
                      fontFamily: 'BerlinSans',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Center(
        child: Text(
          'تفاصيل الصندوق',
          textAlign: TextAlign.right,
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _detailsTopCircleButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel({
    required List<String> imageUrls,
    required double rating,
  }) {
    final hasImages = imageUrls.isNotEmpty;

    if (_currentImageIndex >= imageUrls.length && imageUrls.isNotEmpty) {
      _currentImageIndex = 0;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: double.infinity,
              height: 240,
              child: hasImages
                  ? PageView.builder(
                controller: _imagePageController,
                physics: const BouncingScrollPhysics(),
                itemCount: imageUrls.length,
                onPageChanged: (index) {
                  setState(() => _currentImageIndex = index);
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    imageUrls[index],
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return Container(
                        color: AppColors.inputFill,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  );
                },
              )
                  : _imagePlaceholder(),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: _ratingBadge(rating),
          ),
          if (imageUrls.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: _imageDots(imageUrls.length),
            ),
        ],
      ),
    );
  }

  Widget _ratingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.yellow,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageDots(int count) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            count,
                (index) {
              final isActive = index == _currentImageIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 16 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 240,
      color: AppColors.inputFill,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.hint,
        size: 46,
      ),
    );
  }

  Widget _buildTitleAndDescription(KitModel kit) {
    final mindsetLabel = _mindsetLabel(kit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            kit.name,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
        ),
        if (kit.description.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              kit.description,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.7,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
        if (mindsetLabel.isNotEmpty) ...[
          const SizedBox(height: 12),
          _mindsetBadge(mindsetLabel),
        ],
      ],
    );
  }

  Widget _mindsetBadge(String label) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.14),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChips(
      KitModel kit, {
        required int activitiesCount,
      }) {
    final chips = <Widget>[];

    if (kit.age > 0) {
      chips.add(
        _infoChip(
          icon: Icons.face_rounded,
          title: 'العمر',
          value: '${kit.age}–${kit.age + 3} سنوات',
          color: const Color(0xFFFF7C87),
          lightColor: const Color(0xFFFFF5F6),
        ),
      );
    }

    final typeLabel = kitTypeArabicLabel(kit.type);
    if (typeLabel.isNotEmpty) {
      chips.add(
        _infoChip(
          icon: Icons.category_rounded,
          title: 'النوع',
          value: typeLabel,
          color: const Color(0xFF52C7B3),
          lightColor: const Color(0xFFF3FCF9),
        ),
      );
    }

    if (activitiesCount > 0) {
      chips.add(
        _infoChip(
          icon: Icons.extension_rounded,
          title: 'الأنشطة',
          value: '$activitiesCount نشاط',
          color: const Color(0xFF72B7F4),
          lightColor: const Color(0xFFF4F9FF),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int index = 0; index < chips.length; index++) ...[
            Expanded(child: chips[index]),
            if (index != chips.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color lightColor,
  }) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white.withValues(alpha: 0.99),
            lightColor,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.07),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.018),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              bottom: -12,
              left: -8,
              right: -8,
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.075),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: _chipDecorDot(color.withValues(alpha: 0.18), 6),
            ),
            Positioned(
              top: 28,
              right: 18,
              child: _chipDecorDot(color.withValues(alpha: 0.14), 5),
            ),
            Positioned(
              top: 18,
              right: 34,
              child: Icon(
                Icons.star_rounded,
                size: 9,
                color: color.withValues(alpha: 0.20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
              child: Column(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.97),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.10),
                          blurRadius: 9,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 21,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: color,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 54,
                    height: 1.1,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.23),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Expanded(
                    child: Center(
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: const Color(0xFF17233D),
                          fontSize: value.length > 12 ? 13.5 : 15,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
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

  Widget _chipDecorDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }



  Widget _buildInsideSection(List<String> items) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -15,
            right: -15,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.055),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -15,
            child: Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.yellow.withValues(alpha: 0.13),
              ),
            ),
          ),

          Positioned(
            top: 30,
            left: -28,
            child: Image.asset(
              'assets/images/details_mascot_peek.png',
              width: 145,
              fit: BoxFit.contain,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'ماذا يوجد في الداخل؟',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                ...items.asMap().entries.map(
                      (entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == items.length - 1 ? 0 : 8,
                      ),
                      child: _insideItemCard(
                        text: item,
                        index: index,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _insideItemCard({
    required String text,
    required int index,
  }) {
    final accentColor = index.isEven ? AppColors.primary : AppColors.secondary;

    return Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.014),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.95),
                width: 1.4,
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              color: accentColor,
              size: 17,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12.7,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildBottomButton(BuildContext context, int kitId) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.88),
            AppColors.secondary.withValues(alpha: 0.92),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: () => _openWebDetails(context, kitId),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.35),
                width: 1.1,
              ),
            ),
            child: Text(
              'مزيد من التفاصيل',
              textAlign: TextAlign.center,
              style: AppTextStyles.button.copyWith(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0.1,
                shadows: [
                  Shadow(
                    color: AppColors.black.withValues(alpha: 0.16),
                    blurRadius: 5,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _openWebDetails(BuildContext context, int kitId) async {
    final uri = Uri.parse('https://talentokids.com/kits/$kitId');

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح رابط تفاصيل الصندوق'),
        ),
      );
    }
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: AppColors.hint,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.read<KitCubit>().getKitById(widget.kitId);
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _kitCarouselImages(KitModel kit) {
    final rawImages = kit.imageUrls.isNotEmpty ? kit.imageUrls : [kit.imageUrl];

    return rawImages
        .map(_normalizeImageUrl)
        .where((image) => image.isNotEmpty)
        .toSet()
        .toList();
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

  String _mindsetLabel(KitModel kit) {
    final mindsetName = kit.mindsetData?.name.trim();

    if (mindsetName != null && mindsetName.isNotEmpty) {
      return mindsetName;
    }

    return kit.mindset.trim();
  }
}