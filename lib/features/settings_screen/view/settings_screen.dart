import 'package:flutter/material.dart';
import 'package:ninjachiken/features/global/services/music_service.dart';
import 'package:ninjachiken/features/global/widgets/custom_app_bar.dart';
import 'package:ninjachiken/features/global/widgets/custom_divider.dart';
import 'package:ninjachiken/features/global/widgets/gradiend_scaffold.dart';
import 'package:ninjachiken/features/settings_screen/widgets/settings_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSoundEnabled = true;

  @override
  void initState() {
    super.initState();
    isSoundEnabled = MusicService().isEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const CustomAppBar(title: 'Settings'),
            const SizedBox(height: 10),
            const CustomDivider(),
            SettingsCard(
              title: 'Music',
              value: isSoundEnabled,
              onChanged: (val) async {
                setState(() {
                  isSoundEnabled = val;
                });
                if (val) {
                  await MusicService().enable();
                } else {
                  await MusicService().disable();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
