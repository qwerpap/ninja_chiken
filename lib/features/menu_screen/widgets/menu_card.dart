import 'package:flutter/material.dart';
import 'package:ninjachiken/constants/image_source.dart';
import 'package:ninjachiken/features/global/services/size_helper.dart';
import 'package:ninjachiken/features/global/widgets/pressable_container.dart';
import 'package:ninjachiken/features/menu_screen/data/models/menu_model.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.data});
  final MenuModel data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PressableContainer(
        width: SizeHelper.getRelativeWidth(context, 292),
        height: SizeHelper.getRelativeHeight(context, 86),
        defaultImage: ImageSource.menuButton,
        pressedImage: ImageSource.activeMenuButton,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: data.screenBuilder),
          );
        },
        child: Transform.translate(
          offset: const Offset(0, -8),
          child: Text(data.title, style: AppTextStyles.poppins45s500w),
        ),
      ),
    );
  }
}
