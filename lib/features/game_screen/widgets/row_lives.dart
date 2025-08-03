import 'package:flutter/material.dart';

class RowLives extends StatelessWidget {
  const RowLives({super.key, required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.4),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInBack,
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Image.asset(
              index < lives
                  ? 'assets/png/active_heart.png'
                  : 'assets/png/broken_heart.png',
              key: ValueKey(index < lives),
              height: 38,
            ),
          ),
        ),
      ),
    );
  }
}
