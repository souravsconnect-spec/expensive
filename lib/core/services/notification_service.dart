import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    print("NOTIF_DEBUG: Calling initialize...");
    try {
      await _notificationsPlugin.initialize(settings: initSettings);
      print("NOTIF_DEBUG: Notification plugin initialized");
    } catch (e) {
      print("NOTIF_DEBUG: FAILED TO INITIALIZE NOTIFICATIONS: $e");
    }

    // Request permissions for Android 13+
    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (e) {
      print("Notification permission error: $e");
    }
  }

  Future<void> showNotification(String title, String body) async {
    print("NOTIF_DEBUG: Showing notification: $title - $body");

    // Explicitly create the channel for better support on Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'budget_alerts_channel',
      'Budget Limit Alerts',
      description: 'Notifications for when you exceed your budget limit',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'budget_ticker',
          playSound: true,
          enableVibration: true,
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
