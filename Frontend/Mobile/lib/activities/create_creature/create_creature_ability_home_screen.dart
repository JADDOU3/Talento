import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/activities/create_creature/create_creature_cubit.dart';
import '../../cubits/activities/create_creature/create_creature_state.dart';
import '../../shared/layout/app_background.dart';
import 'create_creature_story_screen.dart';
import 'widgets/create_creature_app_bar.dart';
import 'widgets/option_picker_widget.dart';

class CreateCreatureAbilityHomeScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const CreateCreatureAbilityHomeScreen({
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
      child: _CreateCreatureAbilityHomeView(
        activityId: activityId,
        activitySessionId: activitySessionId,
        childId: childId,
        sessionId: sessionId,
      ),
    );
  }
}

class _CreateCreatureAbilityHomeView extends StatefulWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const _CreateCreatureAbilityHomeView({
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  @override
  State<_CreateCreatureAbilityHomeView> createState() =>
      _CreateCreatureAbilityHomeViewState();
}

class _CreateCreatureAbilityHomeViewState
    extends State<_CreateCreatureAbilityHomeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToStory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CreateCreatureCubit>(),
          child: CreateCreatureStoryScreen(
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
        if (current is! CreateCreatureStepCompleted || current.step != 'abilityHome') return false;
        return previous is! CreateCreatureStepCompleted || previous.step != 'abilityHome';
      },
      listener: (context, state) {
        if (state is CreateCreatureStepCompleted &&
            state.step == 'abilityHome') {
          _navigateToStory(context);
        }
      },
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;

        final prevLoaded = _extractLoaded(previous);
        final currLoaded = _extractLoaded(current);
        if (prevLoaded == null || currLoaded == null) return true;

        return prevLoaded.abilitySelection != currLoaded.abilitySelection ||
            prevLoaded.homeSelection != currLoaded.homeSelection ||
            prevLoaded.abilityHomeComplete != currLoaded.abilityHomeComplete;
      },
      builder: (context, state) {
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

        final abilityChallenge = loaded.level.challenges
            .where((c) => c.step == 'ability')
            .firstOrNull;
        final homeChallenge = loaded.level.challenges
            .where((c) => c.step == 'home')
            .firstOrNull;

        final cubit = context.read<CreateCreatureCubit>();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: const CreateCreatureAppBar(title: 'قدرة ومكان مخلوقك'),
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
                    if (abilityChallenge != null) ...[
                      OptionPickerWidget(
                        label: 'ماذا يستطيع أن يفعل؟',
                        icons: abilityChallenge.choices
                            .map((c) => c.icon)
                            .toList(),
                        selectedIcon: loaded.abilitySelection,
                        onSelected: cubit.onAbilitySelected,
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (homeChallenge != null) ...[
                      OptionPickerWidget(
                        label: 'أين يعيش؟',
                        icons: homeChallenge.choices
                            .map((c) => c.icon)
                            .toList(),
                        selectedIcon: loaded.homeSelection,
                        onSelected: cubit.onHomeSelected,
                      ),
                      const SizedBox(height: 40),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: loaded.abilityHomeComplete
                            ? () => cubit.onAbilityHomeConfirmed()
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