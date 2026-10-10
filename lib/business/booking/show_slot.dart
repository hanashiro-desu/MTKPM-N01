

/// Đổi nhãn ngày/giờ trên màn hình ("Hôm nay", "Ngày mai", "22/10", "18:30") thành thời điểm chiếu.
DateTime resolveStartsAt(String dateLabel, String time, {DateTime? now}) {
  final base = now ?? DateTime.now();
  final today = DateTime(base.year, base.month, base.day);
  var day = today;

  if (dateLabel == 'Ngày mai') {
    day = today.add(const Duration(days: 1));
  } else if (dateLabel != 'Hôm nay') {
    final match = RegExp(r'^(\d{1,2})/(\d{1,2})$').firstMatch(dateLabel);
    if (match != null) {
      day = DateTime(base.year, int.parse(match[2]!), int.parse(match[1]!));
      if (day.isBefore(today)) day = DateTime(base.year + 1, day.month, day.day);
    }
  }

  final parts = time.split(':');
  final hour = int.tryParse(parts.first) ?? 0;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return DateTime(day.year, day.month, day.day, hour, minute);
}
