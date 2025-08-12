import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ninjachiken/features/global/services/music_service.dart';
import 'package:ninjachiken/features/settings_screen/bloc/settgins_state.dart';
import 'package:ninjachiken/features/settings_screen/bloc/settings_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final MusicService _musicService = MusicService();

  SettingsBloc() : super(const SettingsState()) {
    on<InitializeMusic>(_onInitializeMusic);
    on<LoadSettings>(_onLoadSettings);
    on<ToggleMusic>(_onToggleMusic);

    // Обновлено тут:
    _musicService.player.onPlayerStateChanged.listen((playerState) {
      final isPlaying = playerState == PlayerState.playing;
      if (state.isPlaying != isPlaying) {
        emit(state.copyWith(isPlaying: isPlaying));
      }
    });
  }

  Future<void> _onInitializeMusic(
    InitializeMusic event,
    Emitter<SettingsState> emit,
  ) async {
    if (state.isInitialized) {
      return; // Музыка уже инициализирована
    }

    emit(state.copyWith(isLoading: true));

    try {
      // Загружаем настройки из SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final isMusicEnabled = prefs.getBool('music_enabled') ?? true;

      // Настраиваем аудиоплеер
      await _musicService.player.setReleaseMode(ReleaseMode.loop);
      await _musicService.player.setVolume(0.8);

      emit(
        state.copyWith(
          isMusicEnabled: isMusicEnabled,
          isInitialized: true,
          isLoading: false,
          error: null,
        ),
      );

      // Если музыка включена, начинаем воспроизведение
      if (isMusicEnabled) {
        await _playMusic();
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to initialize music: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    if (!state.isInitialized) {
      add(InitializeMusic());
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final isMusicEnabled = prefs.getBool('music_enabled') ?? true;

      emit(state.copyWith(isMusicEnabled: isMusicEnabled, error: null));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load settings: ${e.toString()}'));
    }
  }

  Future<void> _onToggleMusic(
    ToggleMusic event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Сохраняем настройку в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('music_enabled', event.isEnabled);

      if (event.isEnabled) {
        await _playMusic();
      } else {
        await _stopMusic();
      }

      emit(
        state.copyWith(
          isMusicEnabled: event.isEnabled,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to toggle music: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _playMusic() async {
    try {
      if (state.isPlaying) return;
      await _musicService.play();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to play music: ${e.toString()}'));
    }
  }

  Future<void> _stopMusic() async {
    try {
      await _musicService.stop();
    } catch (e) {
      emit(state.copyWith(error: 'Failed to stop music: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() async {
    await _musicService.dispose();
    return super.close();
  }
}
