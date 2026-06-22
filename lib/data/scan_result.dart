class ScannerResult {
  final String code;
  final String? symbology;
  final DateTime timestamp;

  ScannerResult({required this.code, this.symbology, required this.timestamp});
}