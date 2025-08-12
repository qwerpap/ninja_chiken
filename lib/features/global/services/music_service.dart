import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;

  final AudioPlayer player = AudioPlayer();

  MusicService._internal() {
    _init();
  }

  Future<void> _init() async {
    await player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
  }

  Future<void> play() async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(0.8);
    await player.play(AssetSource('sounds/bg_music.mp3'));
    print("🔊 Music started playing");
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> dispose() async {
    await player.stop(); // Остановим воспроизведение явно
    await player.dispose(); // Освободим ресурсы
  }
}
