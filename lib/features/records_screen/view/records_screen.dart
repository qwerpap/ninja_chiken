import 'package:flutter/material.dart';
import 'package:ninjachiken/features/global/widgets/custom_app_bar.dart';
import 'package:ninjachiken/features/global/widgets/custom_divider.dart';
import 'package:ninjachiken/features/global/widgets/gradiend_scaffold.dart';
import 'package:ninjachiken/features/records_screen/widgets/record_card.dart';
import 'package:ninjachiken/theme/app_colors.dart';
import 'package:ninjachiken/theme/app_text_styles.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const CustomAppBar(title: 'Records'),
            const CustomDivider(),
            const SizedBox(height: 16),
            ListView.separated(
              itemCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder:
                  (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomDivider(),
                  ),
              itemBuilder: (context, index) => const RecordCard(),
            ),
          ],
        ),
      ),
    );
  }
}
