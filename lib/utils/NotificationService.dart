import 'package:TradeWatch/utils/DatabaseHelper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('tradingReminderChannelId', 'tradingReminderChannelName',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true),
        iOS: DarwinNotificationDetails());
  }


  Future checkNotificationsForToday(FlutterLocalNotificationsPlugin flip) async {
    final databaseHelper = DatabaseHelper();

    List<Map<String, dynamic>> companies =
    await databaseHelper.getAllCompanies();

    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    String notificationIdDate = DateFormat('ddMMyyyy').format(currentDate);
    int notificationId = int.parse(notificationIdDate);

    bool hasCompaniesWithTodayDate =
    companies.any((company) => company['date'] == formattedDate);

    DateTime notificationDate = DateTime(currentDate.year,currentDate.month,currentDate.day,23,59,59);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print('------------------NotificationDate-----------------------------------');
    print(prefs.getString("notificationDate"));
    print('---------------------------------------------------------------------');

    if (hasCompaniesWithTodayDate && prefs.getString("notificationDate") != notificationIdDate) {

      print('-------------------------------------------------------------------');
      print('Schedule Notifications Called');
      print('-------------------------------------------------------------------');

      if(prefs.getString("notificationDate") != notificationIdDate){
        prefs.setString("notificationDate", notificationIdDate);
        prefs.setBool("callNotification", true);
      }

      print('------------------NotificationDate--and--CallNotification-------------------------------');
      print(prefs.getString("notificationDate"));
      print(prefs.getBool("callNotification"));
      print('---------------------------------------------------------------------');

      if(prefs.getBool("callNotification") ?? true){
        await scheduleNotifications(notificationDate, notificationId, flip);
        prefs.setBool("callNotification", false);
      }

    }
  }

 Future scheduleNotifications(DateTime notificationDate, int notificationId, FlutterLocalNotificationsPlugin flip) async  {

   await showNotification(
       id: notificationId + 5000,
       title: 'Trading Reminder',
       body: 'Some companies have result day today!',
       scheduledNotificationDateTime: notificationDate,
       flip: flip,
       hour: 15,
       min: 20);

   print('-------------------------------------------------------------------');
   print('Show Notifications Called');
   print('-------------------------------------------------------------------');
   showNotification(
       id: notificationId + 6000,
       title: 'Trading Reminder',
       body: 'Some companies have result day today!',
       scheduledNotificationDateTime: notificationDate,
       flip: flip,
       hour: 15,
       min: 25);

   showNotification(
       id: notificationId + 7000,
       title: 'Trading Reminder',
       body: 'Some companies have result day today!',
       scheduledNotificationDateTime: notificationDate,
       flip: flip,
       hour: 15,
       min: 30);

  }

  Future showNotification(
      {int id = 0,
        String? title,
        String? body,
        String? payLoad,
        required FlutterLocalNotificationsPlugin flip,
        required int hour,
        required int min,
        required DateTime scheduledNotificationDateTime}) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String locationName = prefs.getString('location') ?? 'India/Kolkata';
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation(locationName);
    final now = tz.TZDateTime.now(location);

    final localNotificationDate = tz.TZDateTime.from(scheduledNotificationDateTime, location);

    tz.TZDateTime getNotificationDate() {
      tz.TZDateTime scheduledDate = tz.TZDateTime(location, localNotificationDate.year,
          localNotificationDate.month, localNotificationDate.day, hour, min);
      return scheduledDate;
    }

    print("---------------------------------------------------");
    print("Scheduled Date");
    print(getNotificationDate());
    print("---------------------------------------------------");

    if (getNotificationDate().isAfter(now)) {
      await flip.zonedSchedule(
          id,
          title,
          body,
          getNotificationDate(),
          await notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          //androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);

      print('------------------------------------------------');
      print('Notification scheduled');
      print('------------------------------------------------');
    }

  }
}