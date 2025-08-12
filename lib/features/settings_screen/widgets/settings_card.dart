import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';
import 'package:ninjachiken/theme/app_colors.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged; // Теперь может быть null

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.poppins17s400w.copyWith(
              color: AppColors.whiteColor,
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.purpleColor,
            trackColor: AppColors.greyColor.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}
