import 'package:flutter/material.dart';
import 'package:multi_scanner/data/scan_result.dart';

class History extends StatelessWidget{
  final List<ScannnerResult> history;

  const History({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
          child: Text('No scans yet', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: history.length,
        itemBuilder: (context,i){
        final r =history[i];
        return ListTile(
          title: Text(r.code,style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text(r.symbology ?? 'unknown'),
        );
        }
    );
  }
  


}