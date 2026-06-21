import 'package:multi_scanner/core/enums/scanner_status.dart';
import 'package:multi_scanner/data/scan_result.dart';
import 'package:multi_scanner/scanners/scanner_service.dart';

class HoneywellScannerService implements ScannerService{
  @override
  Future<void> softTrigger() {
    // TODO: implement softTrigger
    throw UnimplementedError();
  }

  @override
  Future<void> start({required void Function(ScannnerResult result) onScan, required void Function(ScannerStatus status, {String? message}) onStatus}) {
    // TODO: implement start
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    // TODO: implement stop
    throw UnimplementedError();
  }

}