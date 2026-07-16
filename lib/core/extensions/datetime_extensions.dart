import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension DateTimeExtensions on DateTime {
  /// Formats as "Jan 15, 2025"
  String get formattedDate => DateFormat('MMM dd, yyyy').format(this);

  /// Formats as "15/01/2025"
  String get shortDate => DateFormat('dd/MM/yyyy').format(this);

  /// Formats as "January 15, 2025"
  String get longDate => DateFormat('MMMM dd, yyyy').format(this);

  /// Formats as "14:30" or "2:30 PM"
  String get formattedTime => DateFormat('HH:mm').format(this);

  /// Formats as "Jan 15, 2025 14:30"
  String get formattedDateTime => DateFormat('MMM dd, yyyy HH:mm').format(this);

  /// "2 hours ago", "3 days ago", etc.
  String get timeAgo => timeago.format(this);

  /// "in 2 hours", "in 3 days", etc.
  String get timeUntil => timeago.format(this, allowFromNow: true);

  /// Days remaining from now.
  int get daysRemaining => difference(DateTime.now()).inDays;

  /// Whether date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Whether date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Whether date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Whether date is in the future.
  bool get isFuture => isAfter(DateTime.now());

  /// Start of day (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// End of day (23:59:59).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Smart formatting: "Today", "Yesterday", or date.
  String get smartFormat {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (difference(DateTime.now()).inDays.abs() < 7) {
      return DateFormat('EEEE').format(this); // Day name
    }
    return formattedDate;
  }

  /// Deadline urgency formatting with color context.
  String get deadlineLabel {
    final days = daysRemaining;
    if (days < 0) return 'Expired';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days <= 7) return '$days days left';
    if (days <= 30) return '${(days / 7).ceil()} weeks left';
    return '${(days / 30).ceil()} months left';
  }
}
