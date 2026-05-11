abstract class MediaState {}

class MediaInitial extends MediaState {}

class MediaUploading extends MediaState {}

class MediaUploaded extends MediaState {
  final String s3Key;

  MediaUploaded(this.s3Key);
}

class MediaError extends MediaState {
  final String message;

  MediaError(this.message);
}