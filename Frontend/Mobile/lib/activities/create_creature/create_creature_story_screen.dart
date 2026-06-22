import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/activities/create_creature/widgets/create_creature_app_bar.dart';
import 'package:mobile/activities/create_creature/widgets/creature_face_widget.dart';
import 'package:record/record.dart';

import '../../cubits/activities/create_creature/create_creature_cubit.dart';
import '../../cubits/activities/create_creature/create_creature_state.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/voice_recorder_widget.dart';
import 'widgets/story_elements_card.dart';

class CreateCreatureStoryScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const CreateCreatureStoryScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return const _CreateCreatureStoryView();
  }
}

class _CreateCreatureStoryView extends StatefulWidget {
  const _CreateCreatureStoryView();

  @override
  State<_CreateCreatureStoryView> createState() =>
      _CreateCreatureStoryViewState();
}

class _CreateCreatureStoryViewState extends State<_CreateCreatureStoryView> {
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  bool _isSubmitting = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _durationTimer;

  @override
  void dispose() {
    _durationTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  CreateCreatureLoaded? _loadedFrom(CreateCreatureState state) {
    if (state is CreateCreatureLoaded) return state;
    if (state is CreateCreatureStepCompleted) return state.previousState;
    return null;
  }

  Future<void> _toggleRecording() async {
    final cubit = context.read<CreateCreatureCubit>();

    if (_isRecording) {
      final path = await _audioRecorder.stop();
      _durationTimer?.cancel();

      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });

      if (path != null && path.isNotEmpty) {
        cubit.onRecordingComplete(path);
      }
      return;
    }

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) return;

    cubit.onRecordingCleared();

    final path =
        '${Directory.systemTemp.path}/creature_story_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(const RecordConfig(), path: path);

    setState(() {
      _isRecording = true;
      _recordingDuration = Duration.zero;
    });

    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isRecording) return;
      setState(() => _recordingDuration += const Duration(seconds: 1));
    });
  }

  Future<void> _onStoryDone(CreateCreatureCubit cubit) async {
    setState(() => _isSubmitting = true);
    await cubit.onStoryDone();
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateCreatureCubit, CreateCreatureState>(
      listener: (context, state) {
        if (state is CreateCreatureActivityComplete) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        if (state is CreateCreatureError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is CreateCreatureError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        }

        final loaded = _loadedFrom(state);

        if (loaded == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final storyChallenge = loaded.level.challenges
            .where((c) => c.step == 'story')
            .firstOrNull;

        final cubit = context.read<CreateCreatureCubit>();

        return Scaffold(
          extendBodyBehindAppBar: true,
          // appBar: AppBar(
          //   title: const Text('قصة مخلوقك'),
          //   leading: IconButton(
          //     icon: const Icon(Icons.arrow_back_ios_new_rounded),
          //     onPressed: () => Navigator.pop(context),
          //   ),
          // ),
          appBar: CreateCreatureAppBar(title: 'قصة مخلوقك'),
          body: Stack(
            fit: StackFit.expand,
            children: [

              const AppBackground(child: SizedBox.expand()),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  // children: [
                  //   CreatureFaceWidget(
                  //     eyesSelection: loaded.eyesSelection,
                  //     mouthSelection: loaded.mouthSelection,
                  //     feelingSelection: loaded.feelingSelection,
                  //   ),
                  //   const SizedBox(height: 16),
                  //   Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       if (storyChallenge != null) ...[
                  //         Text(
                  //           storyChallenge.question,
                  //           textAlign: TextAlign.center,
                  //           style: const TextStyle(
                  //             fontSize: 18,
                  //             fontWeight: FontWeight.w700,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         Text(
                  //           storyChallenge.prompt,
                  //           textAlign: TextAlign.center,
                  //           style: const TextStyle(
                  //             fontSize: 14,
                  //             color: Colors.grey,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 40),
                  //       ],
                  //       VoiceRecorderWidget(
                  //         isRecording: _isRecording,
                  //         recordingDuration: _recordingDuration,
                  //         recordedFilePath: loaded.recordedFilePath,
                  //         onToggleRecording: _toggleRecording,
                  //         onRecordingComplete: cubit.onRecordingComplete,
                  //       ),
                  //       const SizedBox(height: 48),
                  //       SizedBox(
                  //         width: double.infinity,
                  //         height: 56,
                  //         child: ElevatedButton(
                  //           onPressed: loaded.hasRecording &&
                  //               !_isSubmitting &&
                  //               !_isRecording
                  //               ? () => _onStoryDone(cubit)
                  //               : null,
                  //           style: ElevatedButton.styleFrom(
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(28),
                  //             ),
                  //           ),
                  //           child: _isSubmitting
                  //               ? const SizedBox(
                  //             width: 24,
                  //             height: 24,
                  //             child: CircularProgressIndicator(
                  //               strokeWidth: 2,
                  //               color: Colors.white,
                  //             ),
                  //           )
                  //               : const Text(
                  //             'تم',
                  //             style: TextStyle(fontSize: 18),
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(height: 24),
                  //       if (loaded.abilitySelection != null)
                  //         Padding(
                  //           padding: const EdgeInsets.symmetric(horizontal: 8),
                  //           child: Image.asset(
                  //             'assets/images/cards/${loaded.abilitySelection}.png',
                  //             width: 100,
                  //             height: 100,
                  //             fit: BoxFit.contain,
                  //           ),
                  //         ),
                  //       if (loaded.homeSelection != null)
                  //         Padding(
                  //           padding: const EdgeInsets.symmetric(horizontal: 8),
                  //           child: Image.asset(
                  //             'assets/images/cards/${loaded.homeSelection}.png',
                  //             width: 100,
                  //             height: 100,
                  //             fit: BoxFit.contain,
                  //           ),
                  //         ),
                  //     ],
                  //   ),
                  //   const SizedBox(height: 24),
                  //
                  // ],
                  children: [
                    StoryElementsCard(
                      homeSelection: loaded.homeSelection,
                      abilitySelection: loaded.abilitySelection,
                      eyesSelection: loaded.eyesSelection,
                      mouthSelection: loaded.mouthSelection,
                      feelingSelection: loaded.feelingSelection,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'احكِ لنا قصة مخلوقك',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F6E56),
                      ),
                    ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                    child: VoiceRecorderWidget(
                      isRecording: _isRecording,
                      recordingDuration: _recordingDuration,
                      recordedFilePath: loaded.recordedFilePath,
                      onToggleRecording: _toggleRecording,
                      onRecordingComplete: cubit.onRecordingComplete,
                    ),
                ),
                    const SizedBox(height: 32),
                    // CreatureFaceWidget(
                    //   eyesSelection: loaded.eyesSelection,
                    //   mouthSelection: loaded.mouthSelection,
                    //   feelingSelection: loaded.feelingSelection,
                    // ),
                    // const SizedBox(height: 20),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     if (loaded.abilitySelection != null)
                    //       Padding(
                    //         padding: const EdgeInsets.symmetric(horizontal: 8),
                    //         child: Image.asset(
                    //           'assets/images/cards/${loaded.abilitySelection}.png',
                    //           width: 100,
                    //           height: 100,
                    //           fit: BoxFit.contain,
                    //         ),
                    //       ),
                    //     if (loaded.homeSelection != null)
                    //       Padding(
                    //         padding: const EdgeInsets.symmetric(horizontal: 8),
                    //         child: Image.asset(
                    //           'assets/images/cards/${loaded.homeSelection}.png',
                    //           width: 100,
                    //           height: 100,
                    //           fit: BoxFit.contain,
                    //         ),
                    //       ),
                    //   ],
                    // ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: loaded.hasRecording && !_isSubmitting && !_isRecording
                            ? () => _onStoryDone(cubit)
                            : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'تم',
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
