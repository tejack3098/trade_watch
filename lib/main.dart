import 'package:TradeWatch/utils/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:TradeWatch/utils/DatabaseHelper.dart';
import 'package:TradeWatch/utils/TimeZone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/HomePage.dart';
import 'dart:async';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await DatabaseHelper.copyPrepopulatedDatabase();
  tz.Location location = await getTimeZoneLocation();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  if (isFirstLaunch) {
    prefs.setString('location', location.name);
    prefs.setBool('isFirstLaunch', false);
  }

  await NotificationService().initNotificationService();
  runApp(const HomePage());
}

Future<tz.Location> getTimeZoneLocation() async {
  final timeZone = TimeZone();
  String timeZoneName = await timeZone.getTimeZoneName();
  final location = await timeZone.getLocation(timeZoneName);
  return location;
}

