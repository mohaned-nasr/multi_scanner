import 'dart:async';

import 'package:multi_scanner/core/enums/scanner_status.dart';
import 'package:multi_scanner/data/scan_result.dart';
import 'package:multi_scanner/scanners/scanner_service.dart';
import 'package:scanwedge/scanwedge.dart';

class ScanwedgeScannerService implements ScannerService{
  Scanwedge? _plugin;
  StreamSubscription<ScanResult>? _subscription;

  @override
  Future<void> softTrigger() async{
    await _plugin?.toggleScanning();
  }

  @override
  Future<void> start({required void Function(ScannnerResult result) onScan, required void Function(ScannerStatus status, {String? message}) onStatus}) async{
    onStatus(ScannerStatus.initialising);
    try{
      _plugin=await Scanwedge.initialize();
      final supported = await _plugin!.isDeviceSupported;
      if (!supported) {
        onStatus(ScannerStatus.deviceNotSupported);
        return;
      }
      await _plugin?.createScanProfile(ProfileModel(profileName: 'multi_scanner'));// ------> enablebarcode,,,, keep defaults
      _subscription =_plugin!.stream.listen((ScanResult){
        onScan(ScannnerResult(
            code: ScanResult.barcode,
            symbology: ScanResult.barcodeType.name,
            timestamp: DateTime.now()));
      }
      );
      onStatus(ScannerStatus.ready);
    }catch(e){
      onStatus(ScannerStatus.error, message: e.toString());
    }

  }

  @override
  Future<void> stop() async{
    await _subscription?.cancel();
    _subscription=null;
    _plugin=null;
  }
}