// lib/activities/create_creature/create_creature_ability_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/activities/create_creature/widgets/create_creature_app_bar.dart';

import '../../cubits/activities/create_creature/create_creature_cubit.dart';
import '../../cubits/activities/create_creature/create_creature_state.dart';
import '../../shared/layout/app_background.dart';
import 'create_creature_home_screen.dart';
import 'widgets/option_picker_widget.dart';

class CreateCreatureAbilityScreen extends StatefulWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const CreateCreatureAbilityScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  @override
  State<CreateCreatureAbilityScreen> createState() =>
      _CreateCreatureAbilityScreenState();
}

class _CreateCreatureAbilityScreenState
    extends State<CreateCreatureAbilityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreateCreatureCubit>().resumeLoadedState();
    });
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CreateCreatureCubit>(),
          child: CreateCreatureHomeScreen(
            activityId: widget.activityId,
            activitySessionId: widget.activitySessionId,
            childId: widget.childId,
            sessionId: widget.sessionId,

          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateCreatureCubit, CreateCreatureState>(
      listener: (context, state) {
        if (state is CreateCreatureStepCompleted && state.step == 'ability') {
          _navigateToHome(context);
        }
      },
      builder: (context, state) {
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

        final abilityChallenge = loaded.level.challenges
            .where((c) => c.step == 'ability')
            .firstOrNull;

        final cubit = context.read<CreateCreatureCubit>();

        return Scaffold(
          extendBodyBehindAppBar: true,
          // appBar: AppBar(
          //   title: const Text('قدرة مخلوقك'),
          //   leading: IconButton(
          //     icon: const Icon(Icons.arrow_back_ios_new_rounded),
          //     onPressed: () => Navigator.pop(context),
          //   ),
          // ),
          appBar: CreateCreatureAppBar(title: 'قدرة'),
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
                    if (abilityChallenge != null) ...[
                      // Text(
                      //   abilityChallenge.question,
                      //   style: const TextStyle(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      // const SizedBox(height: 12),

                      OptionPickerWidget(
                        label: 'ماذا يستطيع أن يفعل؟',
                        icons: abilityChallenge.choices
                            .map((c) => c.icon)
                            .toList(),
                        selectedIcon: loaded.abilitySelection,
                        onSelected: cubit.onAbilitySelected,
                        //maxOptions: 4,//no more than 5.
                      ),


                      const SizedBox(height: 40),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: loaded.abilitySelection != null
                            ? () => cubit.onAbilityConfirmed()
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