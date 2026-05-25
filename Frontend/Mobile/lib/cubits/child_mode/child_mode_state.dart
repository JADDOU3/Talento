abstract class ChildModeState {}

class ChildModeInitial extends ChildModeState {}

class ChildModeStatus extends ChildModeState {
  final bool isChildMode;
  final bool hasPin;
  final bool isLoading;
  final String? error;

  ChildModeStatus({
    required this.isChildMode,
    required this.hasPin,
    this.isLoading = false,
    this.error,
  });

  ChildModeStatus copyWith({
    bool? isChildMode,
    bool? hasPin,
    bool? isLoading,
    String? error,
  }) {
    return ChildModeStatus(
      isChildMode: isChildMode ?? this.isChildMode,
      hasPin: hasPin ?? this.hasPin,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChildModePinRequired extends ChildModeState {}