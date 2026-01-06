import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('EEE, MMM d, yyyy - HH:mm').format(dateTime);
  }

  static String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static String getRelativeDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isTomorrow(date)) return 'Tomorrow';
    if (isYesterday(date)) return 'Yesterday';
    return formatDate(date);
  }

  static List<DateTime> getWeekDays(DateTime date) {
    final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final List<DateTime> week = [];
    
    for (int i = 0; i < 7; i++) {
      week.add(firstDayOfWeek.add(Duration(days: i)));
    }
    
    return week;
  }

  static String getMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String getDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static String getShortDayOfWeek(DateTime date) {
    return DateFormat('E').format(date);
  }

  static DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  static bool isBetween(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start) && date.isBefore(end);
  }

  static DateTime getNextMonday() {
    final today = DateTime.now();
    int daysUntilMonday = DateTime.monday - today.weekday;
    if (daysUntilMonday <= 0) {
      daysUntilMonday += 7;
    }
    return today.add(Duration(days: daysUntilMonday));
  }

  static DateTime getNextWeekend() {
    final today = DateTime.now();
    int daysUntilSaturday = DateTime.saturday - today.weekday;
    if (daysUntilSaturday <= 0) {
      daysUntilSaturday += 7;
    }
    return today.add(Duration(days: daysUntilSaturday));
  }

  // Tính khoảng cách giữa hai TimeOfDay (tính bằng phút)
  static int getMinutesBetween(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    if (endMinutes >= startMinutes) {
      return endMinutes - startMinutes;
    } else {
      // Nếu endTime qua ngày hôm sau
      return (24 * 60 - startMinutes) + endMinutes;
    }
  }

  // Format TimeOfDay thành string 12h format (3:30 PM)
  static String formatTimeOfDay12Hour(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Format TimeOfDay thành string 24h format (15:30)
  static String formatTimeOfDay24Hour(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Chuyển TimeOfDay sang DateTime (dùng ngày hiện tại)
  static DateTime timeOfDayToDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  // Chuyển DateTime sang TimeOfDay
  static TimeOfDay dateTimeToTimeOfDay(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  // Kiểm tra xem một thời điểm có nằm trong khoảng thời gian không
  static bool isTimeBetween(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    if (startMinutes <= endMinutes) {
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Khoảng thời gian qua đêm (ví dụ: 22:00 đến 02:00)
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }

  // Lấy tên tháng
  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2023, month, 1));
  }

  // Lấy tên ngày trong tuần
  static String getWeekdayName(int weekday) {
    return DateFormat('EEEE').format(DateTime(2023, 1, weekday));
  }

  // Lấy số tuần trong năm
  static int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSince = date.difference(firstDayOfYear).inDays;
    return ((daysSince + firstDayOfYear.weekday - 1) / 7).floor() + 1;
  }

  // Kiểm tra xem có phải là ngày làm việc (thứ 2 - thứ 6)
  static bool isWeekday(DateTime date) {
    return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
  }

  // Kiểm tra xem có phải là ngày cuối tuần
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  // Lấy ngày đầu tiên của tháng
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Lấy ngày cuối cùng của tháng
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Lấy số ngày trong tháng
  static int getDaysInMonth(DateTime date) {
    return getLastDayOfMonth(date).day;
  }

  // Thêm duration vào TimeOfDay
  static TimeOfDay addToTimeOfDay(TimeOfDay time, Duration duration) {
    final dateTime = timeOfDayToDateTime(time);
    final newDateTime = dateTime.add(duration);
    return dateTimeToTimeOfDay(newDateTime);
  }

  // So sánh hai TimeOfDay
  static int compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    final aMinutes = a.hour * 60 + a.minute;
    final bMinutes = b.hour * 60 + b.minute;
    return aMinutes.compareTo(bMinutes);
  }
}