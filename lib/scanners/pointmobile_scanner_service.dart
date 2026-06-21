import 'package:multi_scanner/core/enums/scanner_status.dart';
import 'package:multi_scanner/data/scan_result.dart';
import 'package:multi_scanner/scanners/scanner_service.dart';
import 'package:pointmobile_scanner_advanced/pointmobile_scanner_advanced.dart';

class PointmobileScannerService implements ScannerService {
  void Function(ScannnerResult result)? _onScan;
  @override
  Future<void> softTrigger() async{
    await PMScanner.triggerOnOff(isOn: true);
    await PMScanner.setTriggerTimeout(timeoutSeconds: 5);
  }

  @override
  Future<void> start({
    required void Function(ScannnerResult result) onScan,
    required void Function(ScannerStatus status, {String? message}) onStatus,
  }) async {
    _onScan = onScan;
    onStatus(ScannerStatus.initialising);
    try {
      await PMScanner.initScanner();
      final supported= await PMScanner.isDevicePointMobile();
      if (!supported) {
        onStatus(ScannerStatus.deviceNotSupported);
        return;
      }
      PMScanner.onDecode = _onDecode;
      onStatus(ScannerStatus.ready);
    } catch (e) {
      onStatus(ScannerStatus.error, message: e.toString());
    }
  }

  @override
  Future<void> stop() async{
    PMScanner.onDecode = null;
    _onScan = null;
  }

  void _onDecode(Symbology symbology, String barcodeNumber) {
    _onScan?.call(
      ScannnerResult(
        code: barcodeNumber,
        timestamp: DateTime.now(),
        symbology: symbology.name,
      ),
    );
  }
}
