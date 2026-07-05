import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/activities/create_creature/widgets/create_creature_app_bar.dart';
import 'package:record/record.dart';

import '../../cubits/activities/create_creature/create_creature_cubit.dart';
import '../../cubits/activities/create_creature/create_creature_state.dart';
import '../../shared/layout/app_background.dart';
import 'icon_arabic_labels.dart';
import 'widgets/story_elements_card.dart';
import 'widgets/voice_recorder_widget.dart';
import '../../screens/roadmap/roadmap_screen.dart';

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
  final ScrollController _scrollController = ScrollController();

  bool _isRecording = false;
  bool _isSubmitting = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _durationTimer;

  @override
  void dispose() {
    _durationTimer?.cancel();
    _audioRecorder.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  CreateCreatureLoaded? _loadedFrom(CreateCreatureState state) {
    if (state is CreateCreatureLoaded) return state;
    if (state is CreateCreatureStepCompleted) return state.previousState;
    if (state is CreateCreatureVoiceCheckFailed) return state.previousState;
    return null;
  }

  CreateCreatureVoiceCheckFailed? _failureFrom(CreateCreatureState state) {
    if (state is CreateCreatureVoiceCheckFailed) return state;
    return null;
  }

  bool _missingKeywordsEqual(List<String>? a, List<String>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
          Navigator.of(context).popUntil(
                (route) =>
            route.settings.name == RoadmapScreen.routeName || route.isFirst,
          );
        }

        if (state is CreateCreatureError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;

        final prevLoaded = _loadedFrom(previous);
        final currLoaded = _loadedFrom(current);
        if (prevLoaded == null || currLoaded == null) return true;

        final relevantChanged =
            prevLoaded.genderSelection != currLoaded.genderSelection ||
                prevLoaded.hairColorSelection != currLoaded.hairColorSelection ||
                prevLoaded.eyesSelection != currLoaded.eyesSelection ||
                prevLoaded.mouthSelection != currLoaded.mouthSelection ||
                prevLoaded.feelingSelection != currLoaded.feelingSelection ||
                prevLoaded.abilitySelection != currLoaded.abilitySelection ||
                prevLoaded.homeSelection != currLoaded.homeSelection ||
                prevLoaded.recordedFilePath != currLoaded.recordedFilePath;
        // prevLoaded.creatureBaseImageUrl != currLoaded.creatureBaseImageUrl ||
        // prevLoaded.creatureImageLoading != currLoaded.creatureImageLoading;

        if (relevantChanged) return true;

        final prevFailure = _failureFrom(previous);
        final currFailure = _failureFrom(current);

        if (prevFailure?.transcribedText != currFailure?.transcribedText) {
          return true;
        }

        return !_missingKeywordsEqual(
          prevFailure?.missingKeywords,
          currFailure?.missingKeywords,
        );
      },
      builder: (context, state) {
        if (state is CreateCreatureError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        }

        final loaded = _loadedFrom(state);
        final failure = _failureFrom(state);

        if (loaded == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final abilityKeyword = iconArabicLabels[loaded.abilitySelection];
        final homeKeyword = iconArabicLabels[loaded.homeSelection];

        final abilityMissing = failure != null &&
            abilityKeyword != null &&
            failure.missingKeywords.contains(abilityKeyword);
        final homeMissing = failure != null &&
            homeKeyword != null &&
            failure.missingKeywords.contains(homeKeyword);

        final cubit = context.read<CreateCreatureCubit>();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: const CreateCreatureAppBar(title: 'حكاية بطلك!'),
          body: Stack(
            fit: StackFit.expand,
            children: [
              const AppBackground(child: SizedBox.expand()),
              SafeArea(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 24,
                  ),
                  children: [
                    StoryElementsCard(
                      genderSelection: loaded.genderSelection,
                      hairColorSelection: loaded.hairColorSelection,
                      homeSelection: loaded.homeSelection,
                      abilitySelection: loaded.abilitySelection,
                      eyesSelection: loaded.eyesSelection,
                      mouthSelection: loaded.mouthSelection,
                      feelingSelection: loaded.feelingSelection,
                      // creatureBaseImageUrl: loaded.creatureBaseImageUrl,
                      // creatureImageLoading: loaded.creatureImageLoading ?? false,
                      abilityMissing: abilityMissing,
                      homeMissing: homeMissing,
                    ),
                    if (failure != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFC9C9)),
                        ),
                        child: Text(
                          'قصتك لم تذكر: ${failure.missingKeywords.join('، ')}\nحاول مرة أخرى!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFB23B3B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'احكِ لنا حكاية بطلك!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
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
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: loaded.hasRecording &&
                            !_isSubmitting &&
                            !_isRecording
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