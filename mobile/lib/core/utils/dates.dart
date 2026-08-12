const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Formats like `Today, 09:41`, `Yesterday, 16:18` or `28 July 2026`.
String formatRelativeDateTime(DateTime value, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final local = value.toLocal();

  final today = DateTime(reference.year, reference.month, reference.day);
  final thatDay = DateTime(local.year, local.month, local.day);
  final dayDiff = today.difference(thatDay).inDays;

  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

  if (dayDiff == 0) {
    return 'Today, $time';
  }
  if (dayDiff == 1) {
    return 'Yesterday, $time';
  }
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}

/// `9:41 AM` style clock time.
String formatTimeOfDay(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final suffix = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour:${local.minute.toString().padLeft(2, '0')} $suffix';
}
