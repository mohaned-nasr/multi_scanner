import 'package:flutter/material.dart';
import 'package:multi_scanner/providers/scanner_provider.dart';
import 'package:multi_scanner/scanners/scanner_factory.dart';
import 'package:multi_scanner/screens/scan_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp( ChangeNotifierProvider(
    create: (_) => ScannerProvider(factory: ScannerFactory()),
    child: const MaterialApp(home: ScanScreen()),
  ),
  );
}

