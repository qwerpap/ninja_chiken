import 'package:flutter/material.dart';
import 'package:ninjachiken/theme/app_colors.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Text(
            'Privacy Policy',
            style: AppTextStyles.poppins17s400w.copyWith(
              color: AppColors.greyColor,
              decoration:
                  TextDecoration.none, // отключаем стандартное подчёркивание
            ),
          ),
          Positioned(
            bottom: 1,
            child: Container(
              height: 1,
              width:
                  110, // ширину подберите под длину текста вручную или измерьте
              color: AppColors.greyColor,
            ),
          ),
        ],
      ),
    );
  }
}
