// String Utilities for FitX

extension StringExtension on String {
  /// Capitalizes the first letter
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  /// Converts to title case (each word capitalized)
  String get titleCase {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty ? word : word.capitalize)
        .join(' ');
  }

  /// Formats as currency (₹ for Indian food AI)
  String formatAsIndianCurrency() =>
      '₹$this';

  /// Validates email format
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  /// Validates phone number (Indian format)
  bool get isValidIndianPhone {
    final phoneRegex = RegExp(r'^(?:\+91)?[6-9]\d{9}$');
    return phoneRegex.hasMatch(this);
  }

  /// Trims and capitalizes
  String get trimAndCapitalize => trim().titleCase;
}

/// Extension on List for convenience
extension ListExtension<T> on List<T> {
  /// Safe access by index
  T? safeIndex(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }

  /// Chunk list into groups of n
  List<List<T>> chunk(int size) {
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(sublist(i, i + size > length ? length : i + size));
    }
    return result;
  }
}