import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/class_session.dart';

/// Handles local notification initialization and automated 10-minute-before
/// weekly class reminders.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _channelId = 'class_reminders';
  static const String _channelName = 'Class Reminders';
  static const String _channelDescription =
      'Automated reminders 10 minutes before each scheduled class.';

  static const Map<String, int> _weekdayMap = {
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Future<void> init() async {
    if (_initialized || !_isSupportedPlatform) return;

    try {
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Manila'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(settings: initSettings);

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
      await androidImpl?.requestExactAlarmsPermission();

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService.init skipped: $e');
    }
  }

  /// Cancels any previously scheduled reminders and schedules a weekly
  /// recurring notification 10 minutes before each [ClassSession].
  Future<void> scheduleWeeklyClassReminders(List<ClassSession> classes) async {
    if (!_isSupportedPlatform) return;
    if (!_initialized) {
      await init();
    }
    if (!_initialized) return;

    try {
      await _plugin.cancelAll();

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );
      const darwinDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final canExact =
          await androidImpl?.canScheduleExactNotifications() ?? false;
      final scheduleMode = canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      for (var i = 0; i < classes.length; i++) {
        final session = classes[i];
        final scheduledDate = _nextReminderTime(session);
        if (scheduledDate == null) continue;

        await _plugin.zonedSchedule(
          id: i + 1,
          title: 'Upcoming Class: ${session.courseCode}',
          body:
              '${session.courseTitle} starts in 10 minutes (${session.room})',
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: scheduleMode,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: session.id,
        );
      }
    } catch (e) {
      debugPrint('NotificationService.scheduleWeeklyClassReminders skipped: $e');
    }
  }

  /// Computes the next [tz.TZDateTime] 10 minutes before [session] starts.
  tz.TZDateTime? _nextReminderTime(ClassSession session) {
    final targetWeekday = _weekdayMap[session.dayOfWeek.trim().toLowerCase()];
    if (targetWeekday == null) return null;

    final now = tz.TZDateTime.now(tz.local);
    var classTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      session.startHour,
      session.startMinute,
    );

    final daysUntilTarget = (targetWeekday - now.weekday + 7) % 7;
    classTime = classTime.add(Duration(days: daysUntilTarget));

    var reminderTime = classTime.subtract(const Duration(minutes: 10));
    if (!reminderTime.isAfter(now)) {
      reminderTime = reminderTime.add(const Duration(days: 7));
    }

    return reminderTime;
  }
}
