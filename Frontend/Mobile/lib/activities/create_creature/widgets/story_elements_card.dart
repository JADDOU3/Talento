import 'package:flutter/material.dart';
import 'story_element_item.dart';

import 'creature_face_widget.dart';

class StoryElementsCard extends StatelessWidget {
  final String? homeSelection;
  final String? abilitySelection;
  final String? eyesSelection;
  final String? mouthSelection;
  final String? feelingSelection;

  const StoryElementsCard({
    super.key,
    required this.homeSelection,
    required this.abilitySelection,
    required this.eyesSelection,
    required this.mouthSelection,
    required this.feelingSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'عناصر قصتك',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F6E56),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StoryElementItem(
                label: 'المكان',
                bgColor: const Color(0xFFE1F5EE),
                icon: homeSelection != null
                    ? Image.asset(
                  'assets/images/cards/$homeSelection.png',
                  fit: BoxFit.contain,
                )
                    : const Icon(Icons.image_outlined, color: Colors.grey),
              ),
              StoryElementItem(
                label: 'الحدث',
                bgColor: const Color(0xFFFAEEDA),
                icon: abilitySelection != null
                    ? Image.asset(
                  'assets/images/cards/$abilitySelection.png',
                  fit: BoxFit.contain,
                )
                    : const Icon(Icons.bolt_outlined, color: Colors.grey),
              ),
              StoryElementItem(
                label: 'الشخصية',
                bgColor: const Color(0xFFE6F1FB),
                icon: SizedBox(
                  width: 44,
                  height: 44,
                  child: CreatureFaceWidget(
                    eyesSelection: eyesSelection,
                    mouthSelection: mouthSelection,
                    feelingSelection: feelingSelection,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}