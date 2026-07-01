import 'package:flutter/material.dart';

class StoryValidationCards extends StatelessWidget {
  final String? abilitySelection;
  final String? homeSelection;
  final bool abilityMissing;
  final bool homeMissing;

  const StoryValidationCards({
    super.key,
    required this.abilitySelection,
    required this.homeSelection,
    this.abilityMissing = false,
    this.homeMissing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCard(icon: abilitySelection, label: 'القدرة', missing: abilityMissing),
        const SizedBox(width: 16),
        _buildCard(icon: homeSelection, label: 'المكان', missing: homeMissing),
      ],
    );
  }

  Widget _buildCard({
    required String? icon,
    required String label,
    required bool missing,
  }) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: missing ? Colors.redAccent : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: icon != null
              ? Image.asset(
            'assets/images/cards/$icon.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/kit1.png',
              fit: BoxFit.contain,
            ),
          )
              : const Icon(Icons.image_outlined, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: missing ? Colors.redAccent : Colors.black87,
          ),
        ),
      ],
    );
  }
}