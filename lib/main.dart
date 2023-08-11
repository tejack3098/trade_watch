import 'package:TradeWatch/utils/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:TradeWatch/utils/DatabaseHelper.dart';
import 'package:TradeWatch/utils/TimeZone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'Screens/HomePage.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {

    // initialise the plugin of flutterlocalnotifications.
    FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

    // app_icon needs to be a added as a drawable
    // resource to the Android head project.
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

    flip.initialize(initializationSettings);

    switch(task) {

      case 'dailyDatabaseCheck_Periodic' :
        await NotificationService().checkNotificationsForToday(flip);
        break;
    }

    return Future.value(true);
  });

}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Permission.notification.request();
  await Permission.location.request();
  await Permission.ignoreBatteryOptimizations.request();
  await DatabaseHelper.copyPrepopulatedDatabase();
  tz.Location location = await getTimeZoneLocation();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  await Workmanager().registerPeriodicTask(
      "periodicTask", // Task ID
      "dailyDatabaseCheck_Periodic", // Task Name
      inputData: <String, dynamic>{}, // Input data if needed
      //initialDelay: const Duration(minutes:2),
      frequency: const Duration(minutes: 15), // Run Daily
      constraints: Constraints(networkType: NetworkType.not_required)
  );

  print('--------------------------------------------');
  print('periodic task registered');
  print('-------------------------------------------');

  if (isFirstLaunch) {

    prefs.setString('location', location.name);
    prefs.setBool('isFirstLaunch', false);

  }

  runApp(const HomePage());
}

Future<tz.Location> getTimeZoneLocation() async {
  final timeZone = TimeZone();
  String timeZoneName = await timeZone.getTimeZoneName();
  final location = await timeZone.getLocation(timeZoneName);
  return location;
}

