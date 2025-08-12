abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class ToggleMusic extends SettingsEvent {
  final bool isEnabled;
  
  ToggleMusic(this.isEnabled);
}

class InitializeMusic extends SettingsEvent {}