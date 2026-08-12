const _zmw = 'ZMW';

/// Formats [value] as e.g. `ZMW 1,530.00`.
String formatZmw(double value) {
  return '$_zmw ${_formatDecimal(value)}';
}

/// Formats [value] with an explicit sign, e.g. `+ZMW 15.00` / `-ZMW 5.00`.
String formatZmwSigned(double value) {
  final formatted = _formatDecimal(value.abs());
  final sign = value < 0 ? '-' : '+';
  return '$sign$_zmw $formatted';
}

/// Parses user input like `ZMW 1,200.00`, `1 200` or `1200` into a number.
double? parseMoney(String input) {
  final cleaned = input
      .replaceAll('ZMW', '')
      .replaceAll('K', '')
      .replaceAll(',', '')
      .replaceAll(' ', '')
      .trim();
  return double.tryParse(cleaned);
}

String _formatDecimal(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final digits = parts.first;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && (remaining - 1) % 3 == 0) {
      buffer.write(',');
    }
  }
  return '$buffer.${parts.last}';
}
