import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/activities/create_creature/widgets/create_creature_app_bar.dart';
import 'package:mobile/activities/create_creature/widgets/creature_face_widget.dart';

import '../../cubits/activities/create_creature/create_creature_cubit.dart';
import '../../cubits/activities/create_creature/create_creature_state.dart';
import '../../shared/layout/app_background.dart';
import 'create_creature_ability_home_screen.dart';
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
  State<_CreateCreatureFaceView> createState() => _CreateCreatureFaceViewState();
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

  CreateCreatureLoaded? _extractLoaded(CreateCreatureState s) {
    if (s is CreateCreatureLoaded) return s;
    if (s is CreateCreatureStepCompleted) return s.previousState;
    if (s is CreateCreatureVoiceCheckFailed) return s.previousState;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateCreatureCubit, CreateCreatureState>(
      listenWhen: (previous, current) {
        if (current is! CreateCreatureStepCompleted || current.step != 'face') return false;
        return previous is! CreateCreatureStepCompleted || previous.step != 'face';
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
            // prevLoaded.creatureBaseImageUrl != currLoaded.creatureBaseImageUrl ||
            // prevLoaded.creatureImageLoading != currLoaded.creatureImageLoading ||
            prevLoaded.faceComplete != currLoaded.faceComplete;
      },
      builder: (context, state) {
        //debugPrint('FACE BUILD ${DateTime.now()}');
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

        final loaded = _extractLoaded(state);

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
          appBar: const CreateCreatureAppBar(title: 'كيف يبدو بطلك؟'),
          body: Stack(
            fit: StackFit.expand,
            children: [
              const AppBackground(child: SizedBox.expand()),
              SafeArea(
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
                        icons: eyesChallenge.choices.map((c) => c.icon).toList(),
                        selectedIcon: loaded.eyesSelection,
                        onSelected: cubit.onEyesSelected,
                        assetFolder: 'assets/images/cards/eyes',
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (mouthChallenge != null) ...[
                      OptionPickerWidget(
                        label: 'ماذا يبدو فمه؟',
                        icons: mouthChallenge.choices.map((c) => c.icon).toList(),
                        selectedIcon: loaded.mouthSelection,
                        onSelected: cubit.onMouthSelected,
                        assetFolder: 'assets/images/cards/mouth',
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (feelingChallenge != null) ...[
                      OptionPickerWidget(
                        label: 'بماذا يشعر بطلك الآن؟',
                        icons: feelingChallenge.choices.map((c) => c.icon).toList(),
                        selectedIcon: loaded.feelingSelection,
                        onSelected: cubit.onFeelingSelected,
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
            ],
          ),
        );
      },
    );
  }
}