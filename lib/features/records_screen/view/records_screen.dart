import 'package:flutter/material.dart';
import 'package:ninjachiken/features/global/services/record_service.dart';
import 'package:ninjachiken/features/global/widgets/custom_app_bar.dart';
import 'package:ninjachiken/features/global/widgets/custom_divider.dart';
import 'package:ninjachiken/features/global/widgets/gradiend_scaffold.dart';
import 'package:ninjachiken/features/records_screen/data/models/record_model.dart';
import 'package:ninjachiken/features/records_screen/widgets/record_card.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<RecordModel> records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final loadedRecords = await RecordsService().getRecords();

    loadedRecords.sort(
      (a, b) => int.parse(b.score).compareTo(int.parse(a.score)),
    );

    final limitedRecords = loadedRecords.take(50).toList();

    setState(() {
      records = limitedRecords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const CustomAppBar(title: 'Records'),
            const SizedBox(height: 10),
            const CustomDivider(),
            const SizedBox(height: 16),
            ListView.separated(
              itemCount: records.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder:
                  (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CustomDivider(),
                  ),
              itemBuilder: (context, index) {
                final record = records[index];
                return RecordCard(data: record);
              },
            ),
          ],
        ),
      ),
    );
  }
}
