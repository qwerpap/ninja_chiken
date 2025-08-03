import 'package:flutter/material.dart';
import 'package:ninjachiken/constants/image_source.dart';
import 'package:ninjachiken/features/global/services/size_helper.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class ScoreContainer extends StatelessWidget {
  const ScoreContainer({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeHelper.getRelativeWidth(context, 149),
      height: 62,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: SizeHelper.getRelativeWidth(context, 35)),
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(ImageSource.scoreBg)),
      ),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInBack,
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Text(
          '$score',
          key: ValueKey(score),
          style: AppTextStyles.poppins26s600w,
        ),
      ),
    );
  }
}
