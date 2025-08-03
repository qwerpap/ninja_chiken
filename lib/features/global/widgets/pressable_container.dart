import 'package:flutter/material.dart';

class PressableContainer extends StatefulWidget {
  const PressableContainer({
    super.key,
    required this.defaultImage,
    required this.pressedImage,
    required this.child,
    this.onTap,
    this.width,
    this.height,
  });

  final String defaultImage;
  final String pressedImage;
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  State<PressableContainer> createState() => _PressableContainerState();
}

class _PressableContainerState extends State<PressableContainer> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) => setState(() => _isPressed = true);
  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              _isPressed ? widget.pressedImage : widget.defaultImage,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
