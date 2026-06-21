import 'package:flutter/widgets.dart';
import 'package:multi_scanner/core/enums/scanner_status.dart';
import 'package:multi_scanner/core/enums/scanner_type.dart';
import 'package:multi_scanner/scanners/scanner_service.dart';
import 'package:multi_scanner/scanners/scanner_factory.dart';

import '../data/scan_result.dart';

class ScannerProvider extends ChangeNotifier{
  final ScannerFactory factory;
  ScannerProvider({ required this.factory});
  ScannerService? active;
  ScannerType? _type;
  ScannerStatus? status=ScannerStatus.initialising;
  String? statusMessage;
  ScannnerResult? _last;
  final List<ScannnerResult> _history = [];

  // getters
  ScannerType? get type => _type;
  ScannnerResult? get last => _last;
  List<ScannnerResult> get history => List.unmodifiable(_history);


///should i boot the app with a default scanner ??
  Future<void> selectScanner(ScannerType type)async{
    await active?.stop();
    active=factory.createScanner(type);
    _type = type;
    status = ScannerStatus.initialising;
    notifyListeners();
    await active!.start(onScan: _onScan, onStatus: _onStatus);
  }
  void _onScan(ScannnerResult result) {
    _last = result;
    _history.insert(0, result);
    notifyListeners();
  }

  void _onStatus(ScannerStatus newStatus, {String? message}) {
    status = newStatus;
    statusMessage = message;
    notifyListeners();
  }

  Future<void> softTrigger() => active?.softTrigger() ?? Future.value();

  @override
  void dispose() {
    active?.stop();
    super.dispose();
  }
}