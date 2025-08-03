import 'package:flutter/material.dart';
import 'package:ninjachiken/features/records_screen/data/models/record_model.dart';
import 'package:ninjachiken/theme/app_colors.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class RecordCard extends StatelessWidget {
  const RecordCard({super.key});

  // final RecordModel data;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'SCORE 2312',
          style: AppTextStyles.poppins17s400w.copyWith(
            color: AppColors.whiteColor,
          ),
        ),
        Text(
          '08/03/2025',
          style: AppTextStyles.poppins17s400w.copyWith(
            color: AppColors.greyColor,
          ),
        ),
      ],
    );
  }
}
