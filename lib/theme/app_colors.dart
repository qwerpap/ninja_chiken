import 'package:flutter/material.dart';

class AppColors {
  static const whiteColor = Colors.white;
  static const white06Color = Color.fromRGBO(255, 255, 255, 0.6);
  static const blackColor = Color.fromRGBO(48, 48, 48, 1);

  static const greyColor = Colors.grey;

  static const purpleColor = Colors.purpleAccent;

  static const grey112Color = Color.fromRGBO(112, 112, 112, 1);

  static const blurAlertBg = Color.fromRGBO(62, 13, 66, 0.6);

  static const gameOverLeftButton = LinearGradient(
    colors: [
      Color.fromRGBO(249, 250, 251, 1),
      Color.fromRGBO(249, 250, 251, 1),
    ],
  );

  static const gameOverRightButton = LinearGradient(
    colors: [
      Color.fromRGBO(161, 129, 158, 1),
      Color.fromRGBO(161, 129, 158, 1),
    ],
  );

  static const whiteGradientColor = LinearGradient(
    colors: [
      Color.fromRGBO(255, 255, 255, 1),
      Color.fromRGBO(255, 255, 255, 1),
    ],
  );

  static const grey184Color = LinearGradient(
    colors: [
      Color.fromRGBO(184, 184, 184, 1),
      Color.fromRGBO(184, 184, 184, 1),
    ],
  );

  static const purpleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color.fromRGBO(50, 8, 58, 1), Color.fromRGBO(125, 37, 106, 1)],
  );

  static const redGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color.fromRGBO(253, 98, 98, 1), Color.fromRGBO(228, 47, 47, 1)],
  );
}
