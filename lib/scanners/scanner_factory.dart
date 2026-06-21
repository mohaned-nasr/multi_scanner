import 'package:multi_scanner/scanners/honeywell_scanner_service.dart';
import 'package:multi_scanner/scanners/pointmobile_scanner_service.dart';
import 'package:multi_scanner/scanners/scanner_service.dart';
import 'package:multi_scanner/scanners/scanwedge_scanner_service.dart';

import '../core/enums/scanner_type.dart';


// todo not a really factory pattern

class ScannerFactory {

  ScannerService createScanner(ScannerType type) {
    switch (type) {
      case ScannerType.honeywell:   return HoneywellScannerService();
      case ScannerType.pointMobile: return PointmobileScannerService();
      case ScannerType.scanwedge:   return ScanwedgeScannerService();
    }
  }
}