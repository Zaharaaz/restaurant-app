import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inisialisasi notifikasi
  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
    );

    // Buat notification channel 
    await _createNotificationChannel();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Buat notification channel untuk Android 8+
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_reminder_channel', // id
      'Pengingat Harian', 
      description: 'Pengingat harian untuk makan siang',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Menjadwalkan notifikasi harian dengan jam & menit custom
  static Future<void> scheduleDailyReminder(int hour, int minute) async {
    try {
      final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // ID notifikasi
        'Pengingat Harian',
        'Jangan lupa makan siang ya',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Pengingat Harian',
            channelDescription: 'Pengingat harian untuk makan siang',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      throw Exception('Gagal mengatur pengingat: $e');
    }
  }

  // Membatalkan semua notifikasi
  static Future<void> cancelReminder() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Hitung waktu selanjutnya sesuai jam & menit yang dipilih
static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final now = DateTime.now();
  final tz.TZDateTime nowTz = tz.TZDateTime.from(now, tz.local);
  
  tz.TZDateTime scheduledDate = tz.TZDateTime(
    tz.local, 
    nowTz.year, 
    nowTz.month, 
    nowTz.day, 
    hour, 
    minute
  );

  // Jika waktu sudah lewat hari ini, jadwalkan untuk besok
  if (scheduledDate.isBefore(nowTz)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  
  debugPrint('Sekarang: $nowTz');
  debugPrint('Dijadwalkan: $scheduledDate');
  
  return scheduledDate;
}

  // Method untuk request permission (Android 13+)
  static Future<bool> requestNotificationPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      try {
        return await androidImplementation.requestNotificationsPermission() ?? false;
      } catch (e) {
        debugPrint('Error requesting permission: $e');
        return true;
      }
    }
    return false;
  }

  // Method untuk cek status permission
  static Future<bool> isNotificationAllowed() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      try {
        return await androidImplementation.areNotificationsEnabled() ?? false;
      } catch (e) {
        debugPrint('Error checking permission: $e');
        return true; 
      }
    }
    return true;
  }
}