import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _instance = FlutterLocalNotificationsPlugin();
  static const _dailyFortuneChanelId = 'daily_fortune';
  static const _dailyFortuneNotifId = 1;

  static Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTap,
  }) async {
    try {
      // Timezone 初期化
      tz.initializeTimeZones();

      // Android 設定
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS 設定
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 通知タップコールバックを設定
      await _instance.initialize(
        initSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
      );

      // Android 8.0+ 用チャネル作成
      const channel = AndroidNotificationChannel(
        _dailyFortuneChanelId,
        'Daily Fortune',
        description: 'Daily fortune notifications',
        importance: Importance.defaultImportance,
        enableVibration: true,
      );
      await _instance
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Android 13+ 通知権限リクエスト
      await _requestNotificationPermission();
      // Android 12+ 正確なアラーム権限リクエスト
      await _requestScheduleExactAlarmPermission();
    } catch (e) {
      debugPrint('NotificationService.initialize error: $e');
    }
  }

  /// 通知権限をリクエスト (Android 13+)
  static Future<void> _requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      debugPrint('Notification permission: $status');
    } catch (e) {
      debugPrint('Request notification permission error: $e');
    }
  }

  /// 正確なアラーム権限をリクエスト (Android 12+)
  static Future<void> _requestScheduleExactAlarmPermission() async {
    try {
      final status = await Permission.scheduleExactAlarm.request();
      debugPrint('Schedule exact alarm permission: $status');
    } catch (e) {
      debugPrint('Request schedule exact alarm permission error: $e');
    }
  }

  /// バックグラウンド通知タップ（トップレベル関数が必要）
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    debugPrint('Background notification tapped: ${response.payload}');
  }

  /// 毎日定時に通知をスケジュール
  static Future<void> scheduleDailyNotification({
    required int hour, // 0-23
    required String title,
    required String body,
  }) async {
    try {
      final scheduledDate = _nextInstanceOf(hour);
      await _instance.zonedSchedule(
        _dailyFortuneNotifId,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _dailyFortuneChanelId,
            'Daily Fortune',
            channelDescription: 'Daily fortune notifications',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('Scheduled daily notification at $scheduledDate');
    } catch (e) {
      debugPrint('Schedule notification error: $e');
    }
  }

  /// 定時通知をキャンセル
  static Future<void> cancelDailyNotification() async {
    try {
      await _instance.cancel(_dailyFortuneNotifId);
      debugPrint('Cancelled daily notification');
    } catch (e) {
      debugPrint('Cancel notification error: $e');
    }
  }

  /// 次の実行時刻を計算
  static tz.TZDateTime _nextInstanceOf(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// リクエスト権限（iOSのみ）
  static Future<bool> requestPermissions() async {
    try {
      final iosPlugin = _instance.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        return await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
            false;
      }
      return false;
    } catch (e) {
      debugPrint('Request permissions error: $e');
      return false;
    }
  }
}
