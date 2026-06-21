import 'package:flutter/material.dart';
import 'package:multi_scanner/providers/scanner_provider.dart';
import 'package:multi_scanner/screens/widgets/history.dart';
import 'package:multi_scanner/screens/widgets/result.dart';
import 'package:multi_scanner/screens/widgets/scanner_menu.dart';
import 'package:provider/provider.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScannerProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Scanner'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ScannerMenu(selected: provider.type),
            const SizedBox(height: 12),
            Result(result: provider.last),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.read<ScannerProvider>().softTrigger(),
              label: const Text('Scan'),
              icon: const Icon(Icons.barcode_reader),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: History(history: provider.history)),
          ],
        ),
      ),
    );
  }
}
