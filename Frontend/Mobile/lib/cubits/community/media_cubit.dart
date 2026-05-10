import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/community/media.dart';
import 'media_state.dart';

class MediaCubit extends Cubit<MediaState> {
  final MediaService _mediaService;

  MediaCubit(this._mediaService) : super(MediaInitial());

  Future<void> uploadMedia(File file) async {
    emit(MediaUploading());

    try {
      final s3Key = await _mediaService.uploadMedia(file);
      emit(MediaUploaded(s3Key));
    } catch (e) {
      emit(MediaError(e.toString()));
    }
  }

  void reset() {
    emit(MediaInitial());
  }
}