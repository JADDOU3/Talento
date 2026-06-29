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
          alignment: Alignment.centerRight,
          child: Text(
            kit.name,
            textAlign: TextAlign.right,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 29,
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
                fontSize: 13.5,
                color: AppColors.textSecondary,
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
          icon: Icons.child_care_rounded,
          title: 'العمر',
          value: '${kit.age}–${kit.age + 3} سنوات',
          color: AppColors.red,
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
          color: AppColors.primary,
        ),
      );
    }

    if (activitiesCount > 0) {
      chips.add(
        _infoChip(
          icon: Icons.extension_rounded,
          title: 'الأنشطة',
          value: '$activitiesCount نشاط',
          color: AppColors.secondary,
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        for (int index = 0; index < chips.length; index++) ...[
          Expanded(child: chips[index]),
          if (index != chips.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.13),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsideSection(List<String> items) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ماذا يوجد في الداخل؟',
            textAlign: TextAlign.right,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...items.map(
              (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InsideItemTile(text: item),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, int kitId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _openWebDetails(context, kitId),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Text(
          'مزيد من التفاصيل',
          style: AppTextStyles.button.copyWith(
            color: AppColors.white,
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