import 'package:flutter/material.dart';
import 'package:ninjachiken/theme/app_colors.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 0.5, color: AppColors.greyColor);
  }
}
