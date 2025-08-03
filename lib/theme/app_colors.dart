import 'package:flutter/material.dart';

class AppColors {
  static const whiteColor = Colors.white;
  static const blackColor = Colors.black;

  static const greyColor = Colors.grey;

  static const purpleColor = Colors.purpleAccent;

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
