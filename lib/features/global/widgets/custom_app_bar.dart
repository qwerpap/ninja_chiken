import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ninjachiken/features/global/widgets/animated_tap.dart';
import 'package:ninjachiken/theme/app_colors.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.poppins45s500w),
            AnimatedTap(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: SvgPicture.asset(
                  'assets/svg/arrow_back.svg',
                  colorFilter: ColorFilter.mode(
                    AppColors.whiteColor,
                    BlendMode.srcIn,
                  ),
                  height: 35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
