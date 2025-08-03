import 'package:flutter/material.dart';
import 'package:ninjachiken/features/global/widgets/animated_tap.dart';
import 'package:ninjachiken/theme/app_colors.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class AlertButton extends StatelessWidget {
  const AlertButton({super.key, required this.title, this.width});

  final String title;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AnimatedTap(
      onTap: () {},
      child: Container(
        height: 54,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.redGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(title, style: AppTextStyles.poppins17s500w),
      ),
    );
  }
}
