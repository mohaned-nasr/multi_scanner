import 'package:multi_scanner/core/enums/scanner_status.dart';
import 'package:multi_scanner/data/scan_result.dart';

abstract class ScannerService {

  Future<void> start({///-------------------> initializing and starting the scanner
    required void Function (ScannnerResult result) onScan,
    required void Function (ScannerStatus status ,{String? message }) onStatus
  });

  Future<void> stop();///--------------------> stopping the scanner and dispatching
  Future<void> softTrigger();
}