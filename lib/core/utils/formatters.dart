import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  /// Format currency: "$9.99"
  static String currency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format file size: "1.5 MB"
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Format percentage: "85%"
  static String percentage(double value) {
    return '${(value * 100).toInt()}%';
  }

  /// Format number with commas: "1,234,567"
  static String number(num value) {
    return NumberFormat('#,###').format(value);
  }

  /// Format compact number: "1.2K", "3.4M"
  static String compactNumber(num value) {
    return NumberFormat.compact().format(value);
  }

  /// Format GPA: "3.50"
  static String gpa(double value) {
    return value.toStringAsFixed(2);
  }

  /// Format rank: "1st", "2nd", "3rd", "4th"
  static String ordinal(int value) {
    if (value >= 11 && value <= 13) return '${value}th';
    switch (value % 10) {
      case 1:
        return '${value}st';
      case 2:
        return '${value}nd';
      case 3:
        return '${value}rd';
      default:
        return '${value}th';
    }
  }

  /// Format duration: "2h 30m"
  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}
