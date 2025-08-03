import 'package:flutter/material.dart';
import 'package:ninjachiken/features/records_screen/data/models/record_model.dart';
import 'package:ninjachiken/theme/app_colors.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class RecordCard extends StatelessWidget {
  final RecordModel data;
  const RecordCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'SCORE ${data.score}',
          style: AppTextStyles.poppins17s400w.copyWith(
            color: AppColors.whiteColor,
          ),
        ),
        Text(
          data.date,
          style: AppTextStyles.poppins17s400w.copyWith(
            color: AppColors.greyColor,
          ),
        ),
      ],
    );
  }
}
