import 'package:multi_scanner/core/enums/scanner_status.dart';
import 'package:multi_scanner/data/scan_result.dart';
import 'package:multi_scanner/scanners/scanner_service.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';

class HoneywellScannerService implements ScannerService{
  HoneywellScanner? scanner;
  @override
  Future<void> softTrigger() async{
    await scanner?.startScanning();
    //scanner?.stopScanning()---------
    //scanner?.softwareTrigger(state)--^
  }

  @override
  Future<void> start({required void Function(ScannerResult result) onScan, required void Function(ScannerStatus status, {String? message}) onStatus}) async{
    onStatus(ScannerStatus.initialising);
    try {
      scanner = HoneywellScanner(onScannerDecodeCallback: (scannedData) {/// it already has an onError callback
        if (scannedData == null) return;
        onScan(
            ScannerResult(
              code: scannedData.code ?? '',
              symbology: scannedData.codeType,
              timestamp: DateTime.now(),
            )
        );
      },
      );
      final supported = await scanner?.isSupported()?? false;
      if(!supported){
        onStatus(ScannerStatus.deviceNotSupported);
        return;
      }
      await scanner?.startScanner();
      onStatus(ScannerStatus.ready);
    }catch(e){
      onStatus(ScannerStatus.error, message: e.toString());
    }
  }

  @override
  Future<void> stop() async{
    await scanner?.disposeScanner();
    scanner=null;

  }

}