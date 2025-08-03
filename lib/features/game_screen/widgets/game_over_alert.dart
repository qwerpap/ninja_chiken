import 'package:flutter/material.dart';
import 'package:ninjachiken/features/game_screen/widgets/alert_button.dart';
import 'package:ninjachiken/features/global/services/size_helper.dart';
import 'package:ninjachiken/theme/app_colors.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class GameOverAlert extends StatelessWidget {
  const GameOverAlert({
    super.key,
    required this.score,
    required this.onRestart,
    required this.onBackToMenu,
  });

  final int score;
  final VoidCallback onRestart;
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
            gradient: AppColors.redGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game Over',
                style: AppTextStyles.poppins47s600w.copyWith(
                  color: AppColors.whiteColor,
                ),
              ),
              const SizedBox(height: 35),
              Text('score', style: AppTextStyles.poppins24s400w),
              Text(
                score.toString(),
                style: AppTextStyles.poppins47s600w.copyWith(
                  color: AppColors.whiteColor,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AlertButton(
                    title: 'Restart',
                    width: SizeHelper.getRelativeWidth(context, 100),
                    textColor: AppColors.grey112Color,
                    color: AppColors.gameOverLeftButton,
                    onTap: onRestart,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: AlertButton(
                      title: 'Back to menu',
                      color: AppColors.gameOverRightButton,
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
