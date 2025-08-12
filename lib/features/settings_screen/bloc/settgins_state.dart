class SettingsState {
  final bool isMusicEnabled;
  final bool isLoading;
  final bool isInitialized;
  final bool isPlaying;
  final String? error;

  const SettingsState({
    this.isMusicEnabled = true,
    this.isLoading = false,
    this.isInitialized = false,
    this.isPlaying = false,
    this.error,
  });

  SettingsState copyWith({
    bool? isMusicEnabled,
    bool? isLoading,
    bool? isInitialized,
    bool? isPlaying,
    String? error,
  }) {
    return SettingsState(
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      error: error,
    );
  }
}