import 'package:flutter/material.dart';
import 'package:ninjachiken/features/game_screen/widgets/alert_button.dart';
import 'package:ninjachiken/features/global/services/size_helper.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
      ), // 90% ширины
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Pause', style: AppTextStyles.poppins47s600w),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AlertButton(
                // width: SizeHelper.getRelativeWidth(context, 116),
                title: 'Resume',
              ),
              SizedBox(width: 13),
              AlertButton(
                width: SizeHelper.getRelativeWidth(context, 160),
                title: 'Back to menu',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
