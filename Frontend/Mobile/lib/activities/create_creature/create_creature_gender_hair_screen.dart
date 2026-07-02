import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/activities/create_creature/create_creature_cubit.dart';
import '../../cubits/activities/create_creature/create_creature_state.dart';
import '../../shared/layout/app_background.dart';
import 'create_creature_face_screen.dart';
import 'widgets/create_creature_app_bar.dart';
import 'widgets/option_picker_widget.dart';

class CreateCreatureGenderHairScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const CreateCreatureGenderHairScreen({
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
      child: _CreateCreatureGenderHairView(
        activityId: activityId,
        activitySessionId: activitySessionId,
        childId: childId,
        sessionId: sessionId,
      ),
    );
  }
}

class _CreateCreatureGenderHairView extends StatefulWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const _CreateCreatureGenderHairView({
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  @override
  State<_CreateCreatureGenderHairView> createState() =>
      _CreateCreatureGenderHairViewState();
}

class _CreateCreatureGenderHairViewState
    extends State<_CreateCreatureGenderHairView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToFace(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CreateCreatureCubit>(),
          child: CreateCreatureFaceScreen(
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
        if (current is! CreateCreatureStepCompleted || current.step != 'genderHair') return false;
        return previous is! CreateCreatureStepCompleted || previous.step != 'genderHair';
      },
      listener: (context, state) {
        if (state is CreateCreatureStepCompleted &&
            state.step == 'genderHair') {
          _navigateToFace(context);
        }
      },
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;

        final prevLoaded = _extractLoaded(previous);
        final currLoaded = _extractLoaded(current);
        if (prevLoaded == null || currLoaded == null) return true;

        return prevLoaded.genderSelection != currLoaded.genderSelection ||
            prevLoaded.hairColorSelection != currLoaded.hairColorSelection ||
            prevLoaded.genderHairComplete != currLoaded.genderHairComplete;
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

        final loaded = _extractLoaded(state);

        if (loaded == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final cubit = context.read<CreateCreatureCubit>();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: const CreateCreatureAppBar(title: 'صفات بطلك الخارق!'),
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
                    OptionPickerWidget(
                      label: 'فتاة أم ولد؟',
                      icons: const ['boy', 'girl'],
                      selectedIcon: loaded.genderSelection,
                      onSelected: cubit.onGenderSelected,
                    ),
                    const SizedBox(height: 24),
                    OptionPickerWidget(
                      label: 'ما لون شعره/ها؟',
                      icons: const ['black', 'brown', 'blonde'],
                      selectedIcon: loaded.hairColorSelection,
                      onSelected: cubit.onHairColorSelected,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: loaded.genderHairComplete
                            ? () => cubit.onGenderHairConfirmed()
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