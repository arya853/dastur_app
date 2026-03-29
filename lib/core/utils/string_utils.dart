class StringUtils {
  /// Normalizes grade labels like "5", "Class 5", "grade 5" to a standard "grade5".
  static String normalizeGrade(String raw) {
    final digits = RegExp(r'\d+').firstMatch(raw)?.group(0);
    if (digits != null && digits.isNotEmpty) {
      return 'grade$digits';
    }
    // Fallback logic if no digits found (e.g., Roman Numerals)
    final v = raw.trim().toUpperCase();
    const romanToNumber = {
      'I': '1', 'II': '2', 'III': '3', 'IV': '4', 'V': '5',
      'VI': '6', 'VII': '7', 'VIII': '8', 'IX': '9', 'X': '10',
    };
    if (romanToNumber.containsKey(v)) {
      return 'grade${romanToNumber[v]}';
    }
    return raw.toLowerCase().replaceAll(' ', '');
  }

  /// Normalizes division labels like "a", "A ", "div a" to a standard "A".
  static String normalizeDivision(String raw) {
    // Extract a single letter if possible, otherwise use the whole trimmed string
    final letterMatch = RegExp(r'[A-Za-z]').firstMatch(raw);
    if (letterMatch != null) {
      return letterMatch.group(0)!.toUpperCase();
    }
    return raw.trim().toUpperCase();
  }
}
