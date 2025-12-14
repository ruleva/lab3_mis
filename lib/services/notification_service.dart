import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Local notifications init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(initSettings);

    // Timezone init (needed for scheduling)
    tz.initializeTimeZones();

    // FCM permissions + token (proof that Firebase Messaging is connected)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _fcm.getToken();
    // ignore: avoid_print
    print('FCM permission: ${settings.authorizationStatus}');
    // ignore: avoid_print
    print('FCM token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // ignore: avoid_print
      print('FCM foreground message: ${message.notification?.title}');
    });
  }

  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    // cancel previous schedule
    await _local.cancel(1001);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_random_meal',
      'Daily Random Meal',
      channelDescription: 'Daily reminder to open app and view random recipe',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _local.zonedSchedule(
      1001,
      'Random рецепт на денот',
      'Отвори апликација и види рандом рецепт ',
      scheduled,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
