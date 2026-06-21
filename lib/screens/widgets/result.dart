import 'package:flutter/material.dart';
import 'package:multi_scanner/data/scan_result.dart';

class Result extends StatelessWidget{
  final ScannnerResult? result;

  const Result({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const Text('Scan something…',
          style: TextStyle(fontSize: 18, color: Colors.grey));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(result!.code,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        if (result!.symbology != null)
          Text(result!.symbology!,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}