import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // ✅ Импорт аудиоплеера
import 'package:ninjachiken/constants/image_source.dart';

class PauseButton extends StatefulWidget {
  final VoidCallback onTap;
  const PauseButton({super.key, required this.onTap});

  @override
  State<PauseButton> createState() => _PauseButtonState();
}

class _PauseButtonState extends State<PauseButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  final AudioPlayer _player = AudioPlayer(); // ✅ Создание экземпляра плеера

  Future<void> _playClickSound() async {
    try {
      await _player.play(AssetSource('sounds/click_button.mp3'), volume: 1.0);
    } catch (e) {
      // Можно добавить лог или игнорировать
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) async {
        setState(() => _pressed = false);
        await _playClickSound(); // ✅ Воспроизведение звука
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: SizedBox(
          height: 60,
          width: 60,
          child: Stack(
            children: [
              Image.asset(
                ImageSource.pause,
                height: 60,
                width: 60,
                fit: BoxFit.contain,
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 100),
                opacity: _pressed ? 0.4 : 0.0,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
