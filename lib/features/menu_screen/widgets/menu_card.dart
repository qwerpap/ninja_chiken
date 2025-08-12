import 'package:flutter/material.dart';
import 'package:ninjachiken/constants/image_source.dart';
import 'package:ninjachiken/features/global/services/size_helper.dart';
import 'package:ninjachiken/features/global/widgets/pressable_container.dart';
import 'package:ninjachiken/features/menu_screen/data/models/menu_model.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:ninjachiken/constants/image_source.dart';
import 'package:ninjachiken/features/global/services/size_helper.dart';
import 'package:ninjachiken/features/global/widgets/pressable_container.dart';
import 'package:ninjachiken/features/menu_screen/data/models/menu_model.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.data});
  final MenuModel data;

  Future<void> _playClickSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/click_button.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PressableContainer(
        width: SizeHelper.getRelativeWidth(context, 292),
        height: SizeHelper.getRelativeHeight(context, 86),
        defaultImage: ImageSource.menuButton,
        pressedImage: ImageSource.activeMenuButton,
        onTap: () async {
          await _playClickSound(); // 🔊 играем звук
          Navigator.push(
            context,
            MaterialPageRoute(builder: data.screenBuilder),
          );
        },
        child: Transform.translate(
          offset: const Offset(0, -5),
          child: Text(data.title, style: AppTextStyles.poppins45s500w),
        ),
      ),
    );
  }
}
