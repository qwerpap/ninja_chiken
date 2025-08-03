import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ninjachiken/constants/image_source.dart';

class AnimatedChicken extends StatefulWidget {
  final bool isMoving;
  final bool isPicking;
  final double width;
  final double height;

  const AnimatedChicken({
    super.key,
    required this.isMoving,
    required this.isPicking,
    required this.width,
    required this.height,
  });

  @override
  State<AnimatedChicken> createState() => _AnimatedChickenState();
}

class _AnimatedChickenState extends State<AnimatedChicken> {
  late List<String> walkFrames;
  late List<String> pickFrames;

  int _frameIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    walkFrames = [ImageSource.walk2, ImageSource.walk3, ImageSource.walk4];
    pickFrames = [ImageSource.hit1, ImageSource.hit2];
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedChicken oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isMoving != widget.isMoving ||
        oldWidget.isPicking != widget.isPicking) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _timer?.cancel();
    _frameIndex = 0; // сброс индекса при старте новой анимации

    if (widget.isPicking) {
      _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
        setState(() {
          _frameIndex = (_frameIndex + 1) % pickFrames.length;
        });
      });
    } else if (widget.isMoving) {
      _timer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
        setState(() {
          _frameIndex = (_frameIndex + 1) % walkFrames.length;
        });
      });
    } else {
      setState(() {}); // перерисовать с idle кадром
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagePath =
        widget.isPicking
            ? pickFrames[_frameIndex.clamp(0, pickFrames.length - 1)]
            : widget.isMoving
            ? walkFrames[_frameIndex.clamp(0, walkFrames.length - 1)]
            : ImageSource.idle;

    return Image.asset(imagePath, width: widget.width, height: widget.height);
  }
}
