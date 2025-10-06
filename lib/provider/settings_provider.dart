import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_app/notification/notification_helper.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyReminder = "daily_reminder";
  static const _keyHour = "reminder_hour";
  static const _keyMinute = "reminder_minute";

  bool _isReminderActive = false;
  int _hour = 11;
  int _minute = 0;

  bool get isReminderActive => _isReminderActive;
  int get hour => _hour;
  int get minute => _minute;

  SettingsProvider() {
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _isReminderActive = prefs.getBool(_keyReminder) ?? false;
    _hour = prefs.getInt(_keyHour) ?? 11;
    _minute = prefs.getInt(_keyMinute) ?? 0;
    notifyListeners();
  }

  Future<void> setReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReminder, value);

    if (value) {
      await NotificationHelper.scheduleDailyReminder(_hour, _minute);
    } else {
      await NotificationHelper.cancelReminder();
    }

    _isReminderActive = value;
    notifyListeners();
  }

  Future<void> setReminderTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHour, hour);
    await prefs.setInt(_keyMinute, minute);

    _hour = hour;
    _minute = minute;

    if (_isReminderActive) {
      await NotificationHelper.scheduleDailyReminder(hour, minute);
    }

    notifyListeners();
  }
}
