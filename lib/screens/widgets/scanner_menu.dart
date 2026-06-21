import 'package:flutter/material.dart';
import 'package:multi_scanner/core/enums/scanner_type.dart';
import 'package:multi_scanner/providers/scanner_provider.dart';
import 'package:provider/provider.dart';

class ScannerMenu extends StatelessWidget{

  final ScannerType? selected;

  const ScannerMenu({super.key,required this.selected});

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      hint: const Text('Select Scanner'),
      isExpanded: true,
      value: selected,
        items: ScannerType.values.map((t)=>DropdownMenuItem(value: t,child: Text(t.name))).toList(),
        onChanged: (t) {
          if (t != null) {
            context.read<ScannerProvider>().selectScanner(t);
          }
        }
    );
  }

}