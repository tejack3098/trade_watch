import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {

  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService(){
    return _notificationService;
  }

  NotificationService._internal();

  Random random = Random();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotificationService() async {
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
            'tradingReminderChannelId',
            'tradingReminderChannelName',
            channelDescription:'tradingReminderDescription',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true),
        iOS: DarwinNotificationDetails());
  }

  Future scheduleNotification(
      {
        int? id,
        String? title,
        String? body,
        String? payLoad,
        required DateTime scheduledNotificationDt}) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String locationName = prefs.getString('location') ?? 'India/Kolkata';
    //tz.initializeTimeZones();
    tz.Location location = tz.getLocation(locationName);
    final now = tz.TZDateTime.now(location);

    final localNotificationDate = tz.TZDateTime.from(scheduledNotificationDt, location);

    tz.TZDateTime getNotificationDate() {
      tz.TZDateTime scheduledDate = tz.TZDateTime(
          location,
          localNotificationDate.year,
          localNotificationDate.month,
          localNotificationDate.day,
          localNotificationDate.hour,
          localNotificationDate.minute);
      return scheduledDate;
    }

    print("---------------------------------------------------");
    print("Scheduled Date");
    print(now);
    print(getNotificationDate());
    print("---------------------------------------------------");

    print("---------------------------------------------------");
    print("Notification Id");
    print(id);
    print("---------------------------------------------------");

    if (getNotificationDate().isAfter(now)) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id!,
          title,
          body,
          getNotificationDate(),
          notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);

      print('------------------------------------------------');
      print('Notification scheduled');
      print('------------------------------------------------');
    }

  }

}