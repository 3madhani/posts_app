/// Helper utilities for safe JSON parsing in models.
class JsonParsing {
  JsonParsing._();

  /// Safely parse an integer from various types (int, String, double).
  static int asInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Safely parse a double from various types (double, int, String).
  static double asDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Safely parse a String.
  static String asString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  /// Safely parse a boolean.
  static bool asBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return defaultValue;
  }

  /// Safely parse a List of model objects from a dynamic JSON value.
  static List<T> parseList<T>(
    dynamic jsonList,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (jsonList == null || jsonList is! List) {
      return <T>[];
    }
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map((item) => fromJson(item))
        .toList();
  }

  /// Safely parse a nested `Map<String, dynamic>`.
  static Map<String, dynamic> asMap(dynamic value) {
    if (value == null || value is! Map) {
      return <String, dynamic>{};
    }
    return Map<String, dynamic>.from(value);
  }
}
