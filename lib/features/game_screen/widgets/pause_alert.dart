import 'package:flutter/material.dart';
import 'package:ninjachiken/features/game_screen/widgets/alert_button.dart';
import 'package:ninjachiken/features/global/services/size_helper.dart';
import 'package:ninjachiken/theme/app_colors.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class PauseAlert extends StatelessWidget {
  const PauseAlert({
    super.key,
    required this.score,
    required this.onResume,
    required this.onBackToMenu,
  });

  final int score;
  final VoidCallback onResume;
  final VoidCallback onBackToMenu;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      insetPadding: EdgeInsets.zero, // Убираем внешние отступы
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      content: SizedBox(
        width: screenWidth, // Во всю ширину
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 25,
          ), // Отступы от краёв
          decoration: BoxDecoration(
            gradient: AppColors.whiteGradientColor,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pause',
                style: AppTextStyles.poppins47s600w
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AlertButton(
                    title: 'Resume',
                    width: SizeHelper.getRelativeWidth(context, 100),
                    color: AppColors.redGradient,
                    onTap: onResume,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: AlertButton(
                      title: 'Back to menu',
                      color: AppColors.grey184Color,
                      onTap: onBackToMenu,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
