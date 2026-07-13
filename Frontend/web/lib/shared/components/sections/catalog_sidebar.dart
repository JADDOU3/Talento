// lib/shared/components/sections/catalog_sidebar.dart

import 'package:flutter/material.dart';
import '../../../util/theme/app_colors.dart';
import '../../i18n/catalog_translations.dart';

class CatalogSidebar extends StatefulWidget {
  final String lang;
  final void Function(CatalogFilters filters) onFiltersChanged;

  const CatalogSidebar({
    super.key,
    required this.lang,
    required this.onFiltersChanged,
  });

  @override
  State<CatalogSidebar> createState() => _CatalogSidebarState();
}

// ── Filters model ─────────────────────────────────────────────────────────────
class CatalogFilters {
  final String? selectedAge;
  final Set<String> selectedGoals;
  final double maxPrice;

  const CatalogFilters({
    this.selectedAge,
    required this.selectedGoals,
    required this.maxPrice,
  });
}

class _CatalogSidebarState extends State<CatalogSidebar> {
  String? _selectedAge;

  final Map<String, bool> _goals = {
    'natural_sciences': false,
    'logical_reasoning': false,
    'creative_arts': false,
    'sustainability': false,
  };

  double _maxPrice = 200;

  bool get isAr => widget.lang == 'ar';
  CrossAxisAlignment get _cross =>
      isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start;

  void _notify() {
    widget.onFiltersChanged(CatalogFilters(
      selectedAge: _selectedAge,
      selectedGoals: _goals.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toSet(),
      maxPrice: _maxPrice,
    ));
  }

  void _onLearnMorePressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          t('subscription_title', widget.lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr
                  ? 'احصل على خصم 15% على جميع المنتجات عند الاشتراك في العضوية السنوية'
                  : 'Get 15% off on all products when you subscribe to our annual membership',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              isAr
                  ? '✓ شحن مجاني للطلبات التي تزيد عن 50'
                  : '✓ Free shipping on orders over \$50',
              style: const TextStyle(fontSize: 13, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              isAr
                  ? '✓ وصول مبكر للمنتجات الجديدة'
                  : '✓ Early access to new products',
              style: const TextStyle(fontSize: 13, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              isAr
                  ? '✓ محتوى حصري للمشتركين'
                  : '✓ Exclusive content for subscribers',
              style: const TextStyle(fontSize: 13, color: Colors.green),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isAr ? 'إلغاء' : 'Cancel',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAr ? 'تم الاشتراك بنجاح!' : 'Subscribed successfully!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              isAr ? 'اشترك الآن' : 'Subscribe Now',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: _cross,
        children: [
          _header(),
          const SizedBox(height: 20),
          _section('age_range'),
          const SizedBox(height: 10),
          _agePills(),
          const SizedBox(height: 24),
          _section('learning_goal'),
          const SizedBox(height: 10),
          _learningGoals(),
          const SizedBox(height: 24),
          _section('price_range'),
          const SizedBox(height: 10),
          _priceSlider(),
          const SizedBox(height: 32),
          _subscriptionCard(),
        ],
      ),
    );
  }

  Widget _header() => Text(
    t('filter_by', widget.lang),
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.0,
      color: Colors.black54,
    ),
  );

  Widget _section(String key) => Text(
    t(key, widget.lang),
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
      color: Colors.black45,
    ),
  );

  // ── Age pills ──────────────────────────────────────────────────────────────
  Widget _agePills() {
    // ✅ Updated age ranges to 3-5 and 6-7
    const ages = ['age_3_5', 'age_6_7'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      children: ages.map((age) {
        final isSelected = _selectedAge == age;
        final isDisabled = _selectedAge != null && !isSelected;

        Color bgColor;
        Color textColor;
        Color borderColor;

        if (isSelected) {
          bgColor     = AppColors.teal;
          textColor   = Colors.white;
          borderColor = AppColors.teal;
        } else if (isDisabled) {
          bgColor     = const Color(0xFFFFF0F0);
          textColor   = const Color(0xFFCCCCCC);
          borderColor = const Color(0xFFFFCCCC);
        } else {
          bgColor     = Colors.white;
          textColor   = Colors.black54;
          borderColor = Colors.black12;
        }

        return GestureDetector(
          onTap: isDisabled
              ? null
              : () {
            setState(() =>
            _selectedAge = isSelected ? null : age);
            _notify();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDisabled)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(end: 4),
                    child: Icon(Icons.block,
                        size: 10, color: Color(0xFFFFAAAA)),
                  ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                  child: Text(t(age, widget.lang)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Learning goals ─────────────────────────────────────────────────────────
  Widget _learningGoals() {
    return Column(
      crossAxisAlignment: _cross,
      children: _goals.keys.map((key) {
        final checked = _goals[key]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              setState(() => _goals[key] = !checked);
              _notify();
            },
            child: Row(
              textDirection:
              isAr ? TextDirection.rtl : TextDirection.ltr,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: checked ? AppColors.teal : Colors.white,
                    border: Border.all(
                      color:
                      checked ? AppColors.teal : Colors.black26,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: checked
                      ? const Icon(Icons.check,
                      color: Colors.white, size: 12)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  t(key, widget.lang),
                  style: TextStyle(
                    fontSize: 13,
                    color:
                    checked ? Colors.black87 : Colors.black54,
                    fontWeight: checked
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Price slider ────────────────────────────────────────────────────────────
  Widget _priceSlider() {
    return Column(
      crossAxisAlignment: _cross,
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.teal,
            inactiveTrackColor: Colors.grey.withOpacity(0.2),
            thumbColor: AppColors.teal,
            overlayColor: AppColors.teal.withOpacity(0.15),
            thumbShape:
            const RoundSliderThumbShape(enabledThumbRadius: 7),
            trackHeight: 3,
          ),
          child: Slider(
            value: _maxPrice,
            min: 20,
            max: 200,
            onChanged: (v) {
              setState(() => _maxPrice = v);
              _notify();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('\$20',
                  style: TextStyle(
                      fontSize: 11, color: Colors.black54)),
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

  // ── Subscription card ───────────────────────────────────────────────────────
  Widget _subscriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: _cross,
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
          const SizedBox(height: 8),
          Text(
            t('subscription_title', widget.lang),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
            textAlign: isAr ? TextAlign.right : TextAlign.left,
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _onLearnMorePressed,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white38),
              ),
              child: Text(
                t('learn_more', widget.lang),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}