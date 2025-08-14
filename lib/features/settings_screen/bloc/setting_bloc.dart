import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ninjachiken/features/global/services/music_service.dart';
import 'package:ninjachiken/features/settings_screen/bloc/settgins_state.dart';
import 'package:ninjachiken/features/settings_screen/bloc/settings_event.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final MusicService _musicService = MusicService();

  SettingsBloc() : super(const SettingsState()) {
    on<InitializeMusic>(_onInitializeMusic);
    on<LoadSettings>(_onLoadSettings);
    on<ToggleMusic>(_onToggleMusic);

    // Слушаем изменения состояния плеера
    _musicService.player.onPlayerStateChanged.listen((playerState) {
      final isPlaying = playerState == PlayerState.playing;
      print('Player state changed: $playerState, isPlaying: $isPlaying');
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
      // Настраиваем аудиоплеер
      await _musicService.player.setReleaseMode(ReleaseMode.loop);
      await _musicService.player.setVolume(0.8);

      emit(
        state.copyWith(
          isMusicEnabled: false,
          isInitialized: true,
          isLoading: false,
          error: null,
        ),
      );

      // Музыка всегда выключена при запуске
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
      // Музыка всегда выключена, не загружаем из SharedPreferences
      emit(state.copyWith(isMusicEnabled: false, error: null));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load settings: ${e.toString()}'));
    }
  }

  Future<void> _onToggleMusic(
    ToggleMusic event,
    Emitter<SettingsState> emit,
  ) async {
    print('ToggleMusic event: ${event.isEnabled}');
    emit(state.copyWith(isLoading: true));

    try {
      // Не сохраняем в SharedPreferences, только временно включаем/выключаем

      if (event.isEnabled) {
        print('Enabling music...');
        await _playMusic();
      } else {
        print('Disabling music...');
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
      if (state.isPlaying) {
        print('Music is already playing, skipping...');
        return;
      }
      await _musicService.play();
      print('Music started playing');
    } catch (e) {
      emit(state.copyWith(error: 'Failed to play music: ${e.toString()}'));
    }
  }

  Future<void> _stopMusic() async {
    try {
      if (!state.isPlaying) {
        print('Music is not playing, nothing to stop');
        return;
      }
      await _musicService.stop();
      print('Music stopped');
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
