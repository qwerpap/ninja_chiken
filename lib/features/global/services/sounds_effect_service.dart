import 'package:audioplayers/audioplayers.dart';

class SoundEffectService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    await _player.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: <AVAudioSessionOptions>{},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
  }

  Future<void> playClick() async {
    await _player.play(AssetSource('sounds/click_button.mp3'));
  }

  Future<void> play(String assetPath) async {
    await _player.play(AssetSource(assetPath));
  }
}
