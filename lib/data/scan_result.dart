class ScannnerResult {
  final String code;
  final String? symbology;
  final DateTime timestamp;

  ScannnerResult({required this.code, this.symbology, required this.timestamp});
}