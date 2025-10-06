import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/notification/notification_helper.dart';
import 'package:restaurant_app/provider/settings_provider.dart';
import 'package:restaurant_app/provider/theme_provider.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          // Reminder toggle
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return SwitchListTile(
                title: const Text("Pengingat Harian"),
                subtitle: Text(
                  settings.isReminderActive
                      ? "Aktif • ${settings.hour.toString().padLeft(2, '0')}:${settings.minute.toString().padLeft(2, '0')}"
                      : "Nonaktif",
                ),
                value: settings.isReminderActive,
                onChanged: (value) async {
                  await _toggleReminder(context, value, settings);
                },
              );
            },
          ),

          // Reminder time picker
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              if (!settings.isReminderActive) return const SizedBox.shrink();

              return ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Atur Waktu Pengingat"),
                subtitle: Text(
                  "${settings.hour.toString().padLeft(2, '0')}:${settings.minute.toString().padLeft(2, '0')}",
                ),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: settings.hour,
                      minute: settings.minute,
                    ),
                  );

                  if (picked != null) {
                    // Update waktu di provider
                    await settings.setReminderTime(picked.hour, picked.minute);
                    
                    // Jika reminder aktif, restart dengan waktu baru
                    if (settings.isReminderActive) {
                      await _scheduleNotification(picked.hour, picked.minute);
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Pengingat diatur ke ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}",
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),

          const Divider(),

          // Theme toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return SwitchListTile(
                title: const Text("Mode Gelap"),
                subtitle: const Text("Aktifkan tema gelap"),
                value: themeProvider.isDarkTheme,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _toggleReminder(BuildContext context, bool value, SettingsProvider settings) async {
    try {
      // Update status reminder di provider
      await settings.setReminder(value);
      
      // Handle notifikasi langsung di sini
      if (value) {
        await _scheduleNotification(settings.hour, settings.minute);
      } else {
        await NotificationHelper.cancelReminder();
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Pengingat harian diaktifkan pada ${settings.hour.toString().padLeft(2, '0')}:${settings.minute.toString().padLeft(2, '0')}'
                : 'Pengingat harian dimatikan',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Gagal mengatur pengingat - $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Reset status di provider jika error
      await settings.setReminder(false);
    }
  }

  Future<void> _scheduleNotification(int hour, int minute) async {
    // Cek dan minta izin notifikasi
    bool isAllowed = await NotificationHelper.isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await NotificationHelper.requestNotificationPermission();
    }
    
    if (isAllowed) {
      await NotificationHelper.scheduleDailyReminder(hour, minute);
    } else {
      throw Exception('Izin notifikasi ditolak');
    }
  }
}