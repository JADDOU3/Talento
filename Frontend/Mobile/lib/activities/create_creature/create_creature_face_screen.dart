import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/activities/create_creature/create_creature_cubit.dart';
import '../../cubits/activities/create_creature/create_creature_state.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/top_bar.dart';
import 'create_creature_ability_home_screen.dart';
import 'widgets/creature_face_widget.dart';
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
    return BlocProvider.value(
      value: context.read<CreateCreatureCubit>(),
      child: _CreateCreatureFaceView(
        activityId: activityId,
        activitySessionId: activitySessionId,
        childId: childId,
        sessionId: sessionId,
      ),
    );
  }
}

class _CreateCreatureFaceView extends StatefulWidget {
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

  @override
  State<_CreateCreatureFaceView> createState() =>
      _CreateCreatureFaceViewState();
}

class _CreateCreatureFaceViewState extends State<_CreateCreatureFaceView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToAbilityHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CreateCreatureCubit>(),
          child: CreateCreatureAbilityHomeScreen(
            activityId: widget.activityId,
            activitySessionId: widget.activitySessionId,
            childId: widget.childId,
            sessionId: widget.sessionId,
          ),
        ),
      ),
    );
  }

  CreateCreatureLoaded? _extractLoaded(CreateCreatureState state) {
    if (state is CreateCreatureLoaded) return state;
    if (state is CreateCreatureStepCompleted) return state.previousState;
    if (state is CreateCreatureVoiceCheckFailed) return state.previousState;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateCreatureCubit, CreateCreatureState>(
      listenWhen: (previous, current) {
        if (current is! CreateCreatureStepCompleted ||
            current.step != 'face') {
          return false;
        }

        return previous is! CreateCreatureStepCompleted ||
            previous.step != 'face';
      },
      listener: (context, state) {
        if (state is CreateCreatureStepCompleted && state.step == 'face') {
          _navigateToAbilityHome(context);
        }
      },
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;

        final prevLoaded = _extractLoaded(previous);
        final currLoaded = _extractLoaded(current);

        if (prevLoaded == null || currLoaded == null) return true;

        return prevLoaded.eyesSelection != currLoaded.eyesSelection ||
            prevLoaded.mouthSelection != currLoaded.mouthSelection ||
            prevLoaded.feelingSelection != currLoaded.feelingSelection ||
            prevLoaded.genderSelection != currLoaded.genderSelection ||
            prevLoaded.hairColorSelection != currLoaded.hairColorSelection ||
            prevLoaded.faceComplete != currLoaded.faceComplete;
      },
      builder: (context, state) {
        if (state is CreateCreatureLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is CreateCreatureError) {
          return Scaffold(
            body: Center(
              child: Text(state.message),
            ),
          );
        }

        final loaded = _extractLoaded(state);

        if (loaded == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final faceChallenges = loaded.level.challenges
            .where((challenge) => challenge.step == 'face')
            .toList();

        final eyesChallenge = faceChallenges
            .where((challenge) => challenge.part == 'eyes')
            .firstOrNull;

        final mouthChallenge = faceChallenges
            .where((challenge) => challenge.part == 'mouth')
            .firstOrNull;

        final feelingChallenge = faceChallenges
            .where((challenge) => challenge.part == 'feeling')
            .firstOrNull;

        final cubit = context.read<CreateCreatureCubit>();

        return Scaffold(
          body: AppBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TopBar(
                  leadingIcon: Icons.arrow_back_ios_new_rounded,
                  onLeadingPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      children: [
                        CreatureFaceWidget(
                          genderSelection: loaded.genderSelection,
                          hairColorSelection: loaded.hairColorSelection,
                          eyesSelection: loaded.eyesSelection,
                          mouthSelection: loaded.mouthSelection,
                          feelingSelection: loaded.feelingSelection,
                          // networkBaseImageUrl: loaded.creatureBaseImageUrl,
                          // baseImageLoading: loaded.creatureImageLoading ?? false,
                        ),
                        if (eyesChallenge != null) ...[
                          OptionPickerWidget(
                            label: 'ما شكل عينه؟',
                            icons: eyesChallenge.choices
                                .map((choice) => choice.icon)
                                .toList(),
                            selectedIcon: loaded.eyesSelection,
                            onSelected: cubit.onEyesSelected,
                            assetFolder: 'assets/images/cards/eye',
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (mouthChallenge != null) ...[
                          OptionPickerWidget(
                            label: 'ماذا يبدو فمه؟',
                            icons: mouthChallenge.choices
                                .map((choice) => choice.icon)
                                .toList(),
                            selectedIcon: loaded.mouthSelection,
                            onSelected: cubit.onMouthSelected,
                            assetFolder: 'assets/images/cards/mouth',
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (feelingChallenge != null) ...[
                          OptionPickerWidget(
                            label: 'بماذا يشعر بطلك الآن؟',
                            icons: feelingChallenge.choices
                                .map((choice) => choice.icon)
                                .toList(),
                            selectedIcon: loaded.feelingSelection,
                            onSelected: cubit.onFeelingSelected,
                            showArabicLabels: true,
                            assetFolder: 'assets/images/cards/feeling',
                          ),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}