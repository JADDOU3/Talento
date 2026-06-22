  // lib/activities/create_creature/create_creature_face_screen.dart

  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/activities/create_creature/widgets/create_creature_app_bar.dart';
import 'package:mobile/activities/create_creature/widgets/creature_face_widget.dart';

  import '../../cubits/activities/create_creature/create_creature_cubit.dart';
  import '../../cubits/activities/create_creature/create_creature_state.dart';
  import '../../shared/layout/app_background.dart';
  import 'create_creature_ability_screen.dart';
  import 'widgets/option_picker_widget.dart';

  class CreateCreatureFaceScreen extends StatelessWidget {
    final int activityId;
    final int activitySessionId;
    final int childId;
    final int sessionId;

    const CreateCreatureFaceScreen({
      super.key,
      required this.activityId,
      required this.activitySessionId,
      required this.childId,
      required this.sessionId,
    });

    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (_) => CreateCreatureCubit()
          ..loadGame(
            activityId: activityId,
            activitySessionId: activitySessionId,
            childId: childId,
            sessionId: sessionId,
          ),
        child: _CreateCreatureFaceView(
          activityId: activityId,
          activitySessionId: activitySessionId,
          childId: childId,
          sessionId: sessionId,
        ),
      );
    }
  }

  class _CreateCreatureFaceView extends StatelessWidget {
    final int activityId;
    final int activitySessionId;
    final int childId;
    final int sessionId;

    const _CreateCreatureFaceView({
      required this.activityId,
      required this.activitySessionId,
      required this.childId,
      required this.sessionId,
    });

    void _navigateToAbility(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<CreateCreatureCubit>(),
            child: CreateCreatureAbilityScreen(
              activityId: activityId,
              activitySessionId: activitySessionId,
              childId: childId,
              sessionId: sessionId,
            ),
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return BlocConsumer<CreateCreatureCubit, CreateCreatureState>(
        listener: (context, state) {
          if (state is CreateCreatureStepCompleted && state.step == 'face') {
            _navigateToAbility(context);
          }
        },
        builder: (context, state) {
          if (state is CreateCreatureLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is CreateCreatureError) {
            return Scaffold(
              body: Center(child: Text(state.message)),
            );
          }

          final loaded = state is CreateCreatureLoaded
              ? state
              : state is CreateCreatureStepCompleted
              ? state.previousState
              : null;

          if (loaded == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final faceChallenges = loaded.level.challenges
              .where((c) => c.step == 'face')
              .toList();

          final eyesChallenge =
              faceChallenges.where((c) => c.part == 'eyes').firstOrNull;
          final mouthChallenge =
              faceChallenges.where((c) => c.part == 'mouth').firstOrNull;
          final feelingChallenge =
              faceChallenges.where((c) => c.part == 'feeling').firstOrNull;

          final cubit = context.read<CreateCreatureCubit>();

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: CreateCreatureAppBar(title: 'صمّم وجه مخلوقك'),
            body: Stack(
              fit: StackFit.expand,
              children: [
                const AppBackground(child: SizedBox.expand()),
                SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    children: [
                      CreatureFaceWidget(
                        eyesSelection: loaded.eyesSelection,
                        mouthSelection: loaded.mouthSelection,
                        feelingSelection: loaded.feelingSelection,
                      ),
                      // Container(
                      //   height: 200,
                      //   margin: const EdgeInsets.only(bottom: 24),
                      //   decoration: BoxDecoration(
                      //     color: const Color(0xFFc3ecf3),
                      //     borderRadius: BorderRadius.circular(20),
                      //     border: Border.all(
                      //       color: Colors.white,
                      //       width: 2,
                      //     ),
                      //   ),
                      //   child: const Center(
                      //     child: Icon(
                      //       Icons.help_outline,
                      //       size: 200,
                      //       color: Colors.grey,
                      //     ),
                      //   ),
                      // ),
                      if (eyesChallenge != null) ...[

                        // Center(
                        //     child: Text(
                        //   eyesChallenge.question,
                        //   style: const TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // )
                        // ),
                        // const SizedBox(height: 12),
                        OptionPickerWidget(
                          label: 'ما شكل عينه؟',
                          icons:
                          eyesChallenge.choices.map((c) => c.icon).toList(),
                          selectedIcon: loaded.eyesSelection,
                          onSelected: cubit.onEyesSelected,
                          //maxOptions: 4,

                        )
                        ,


                        const SizedBox(height: 24),
                      ],
                      if (mouthChallenge != null) ...[

                        // Center(
                        // child:Text(
                        //   mouthChallenge.question,
                        //   style: const TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // )
                        // ),
                        // const SizedBox(height: 12),
                        OptionPickerWidget(
                          label: 'ماذا يبدو فمه؟',
                          icons:
                          mouthChallenge.choices.map((c) => c.icon).toList(),
                          selectedIcon: loaded.mouthSelection,
                          onSelected: cubit.onMouthSelected,
                          //maxOptions: 4,
                        )
                        ,

                        const SizedBox(height: 24),
                      ],
                      if (feelingChallenge != null) ...[

                        // Center(
                        //   child: Text(
                        //   feelingChallenge?.question ?? 'ما شعور مخلوقك؟',
                        //   style: const TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // )
                        // ),
                        // const SizedBox(height: 12),
                          OptionPickerWidget(
                            label: 'الشعور',
                            icons: feelingChallenge?.choices.map((c) => c.icon).toList() ?? [],
                            selectedIcon: loaded.feelingSelection,
                            onSelected: cubit.onFeelingSelected,
                          )
                        ,

                        const SizedBox(height: 40),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: loaded.faceComplete
                              ? () => cubit.onFaceConfirmed()
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'التالي',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }