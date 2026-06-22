//
// //import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mobile/activities/create_creature/widgets/story_element_item.dart';
//
// import 'creature_face_widget.dart';
//
// class StoryElementsCard extends StatelessWidget {
//   final String? homeSelection;
//   final String? abilitySelection;
//   final String? eyesSelection;
//   final String? mouthSelection;
//   final String? feelingSelection;
//
//   const StoryElementsCard({
//     super.key,
//     required this.homeSelection,
//     required this.abilitySelection,
//     required this.eyesSelection,
//     required this.mouthSelection,
//     required this.feelingSelection,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const Text(
//           'عناصر قصتك',
//           style: TextStyle(
//             fontSize: 30,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF0F6E56),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               StoryElementItem(
//                 label: 'المكان',
//                 bgColor: const Color(0xFFE1F5EE),
//                 icon: homeSelection != null
//                     ? Image.asset(
//                   'assets/images/cards/$homeSelection.png',
//                   fit: BoxFit.contain,
//                 )
//                     : const Icon(Icons.image_outlined, color: Colors.grey),
//               ),
//               StoryElementItem(
//                 label: 'الحدث',
//                 bgColor: const Color(0xFFFAEEDA),
//                 icon: abilitySelection != null
//                     ? Image.asset(
//                   'assets/images/cards/$abilitySelection.png',
//                   fit: BoxFit.contain,
//                 )
//                     : const Icon(Icons.bolt_outlined, color: Colors.grey),
//               ),
//               StoryElementItem(
//                 label: 'الشخصية',
//                 bgColor: const Color(0xFFE6F1FB),
//                 icon: SizedBox(
//                   width: 44,
//                   height: 44,
//                   child: CreatureFaceWidget(
//                     eyesSelection: eyesSelection,
//                     mouthSelection: mouthSelection,
//                     feelingSelection: feelingSelection,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F1FB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          //width: 100,
                          height: 160,
                          child: CreatureFaceWidget(
                            eyesSelection: eyesSelection,
                            mouthSelection: mouthSelection,
                            feelingSelection: feelingSelection,

                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'الشخصية',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAEEDA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              abilitySelection != null
                                  ? Image.asset(
                                'assets/images/cards/$abilitySelection.png',
                                width: 160,
                                height: 60,
                                fit: BoxFit.contain,
                              )
                                  : const Icon(Icons.bolt_outlined, color: Colors.grey),
                              const SizedBox(height: 4),
                              const Text(
                                'القدرة الخارقة',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F5EE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              homeSelection != null
                                  ? Image.asset(
                                'assets/images/cards/$homeSelection.png',
                                width: 160,
                                height: 60,
                                fit: BoxFit.contain,
                              )
                                  : const Icon(Icons.image_outlined, color: Colors.grey),
                              const SizedBox(height: 4),
                              const Text(
                                'المكان',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
        ),
      ],
    );
  }
}