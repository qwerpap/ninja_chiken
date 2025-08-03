import 'package:flutter/material.dart';

class SizeHelper {
  static const double baseWidth = 353;
  static const double baseHeight = 850;

  static double getRelativeWidth(BuildContext context, double designWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * (designWidth / baseWidth);
  }

  static double getRelativeHeight(BuildContext context, double designHeight) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * (designHeight / baseHeight);
  }
}
