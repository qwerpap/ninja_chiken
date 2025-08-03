import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;

  MusicService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isEnabled = true;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('music_enabled') ?? true;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0.8);

    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _isPlaying = true;
      } else if (state == PlayerState.stopped || state == PlayerState.paused) {
        _isPlaying = false;
      }
    });

    if (_isEnabled) {
      await play();
    }
  }

  Future<void> play() async {
    if (!_isEnabled || _isPlaying) return;
    _isPlaying = true;
    await _player.play(AssetSource('sounds/bg_music.mp3'), volume: 0.8);
  }

  Future<void> stop() async {
    _isPlaying = false;
    await _player.stop();
  }

  Future<void> enable() async {
    _isEnabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', true);
    await play();
  }

  Future<void> disable() async {
    _isEnabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', false);
    await stop();
  }

  bool get isEnabled => _isEnabled;
}
