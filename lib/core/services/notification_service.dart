import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final SharedPreferences _prefs;

  static const String _reminderEnabledKey = 'fitx_workout_reminder_enabled';
  static const String _reminderHourKey = 'fitx_workout_reminder_hour';
  static const String _reminderMinuteKey = 'fitx_workout_reminder_minute';
  static const String _inactivityNudgeKey = 'fitx_inactivity_nudge_enabled';

  NotificationService(this._prefs);

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: darwin);

    try {
      await _plugin.initialize(settings);
    } catch (_) {
      // Graceful fallback on web or unsupported environments
    }
  }

  bool get isReminderEnabled => _prefs.getBool(_reminderEnabledKey) ?? true;
  int get reminderHour => _prefs.getInt(_reminderHourKey) ?? 8;
  int get reminderMinute => _prefs.getInt(_reminderMinuteKey) ?? 0;
  bool get isInactivityNudgeEnabled =>
      _prefs.getBool(_inactivityNudgeKey) ?? true;

  Future<void> setReminderEnabled(bool enabled) async {
    await _prefs.setBool(_reminderEnabledKey, enabled);
    if (!enabled) {
      await cancelNotification(101);
    }
  }

  Future<void> setReminderTime(int hour, int minute) async {
    await _prefs.setInt(_reminderHourKey, hour);
    await _prefs.setInt(_reminderMinuteKey, minute);
  }

  Future<void> setInactivityNudgeEnabled(bool enabled) async {
    await _prefs.setBool(_inactivityNudgeKey, enabled);
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'fitx_channel',
      'FitX Notifications',
      channelDescription: 'Workout & Fitness Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android);

    try {
      await _plugin.show(id, title, body, details);
    } catch (_) {
      // Ignored if notifications not supported in current environment
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }
}
