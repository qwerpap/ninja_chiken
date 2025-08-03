import 'package:flutter/material.dart';
import 'package:ninjachiken/constants/app_data.dart';
import 'package:ninjachiken/constants/image_source.dart';
import 'package:ninjachiken/features/global/widgets/gradiend_scaffold.dart';
import 'package:ninjachiken/features/menu_screen/widgets/menu_card.dart';
import 'package:ninjachiken/features/menu_screen/widgets/privacy_policy.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(ImageSource.appName, width: 260),
                  const SizedBox(height: 40),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: AppData.menuList.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        return MenuCard(data: AppData.menuList[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            PrivacyPolicy(onPressed: () {}),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
