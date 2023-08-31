import 'dart:io';
import 'dart:math';
import 'package:TradeWatch/utils/NotificationService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:TradeWatch/utils/DatabaseHelper.dart';


class ManageCompanyScreen extends StatefulWidget {
  const ManageCompanyScreen({super.key});

  @override
  State<ManageCompanyScreen> createState() => _ManageCompanyScreenState();
}

class _ManageCompanyScreenState extends State<ManageCompanyScreen> {

  final TextEditingController _companyNameController = TextEditingController();
  Random random = Random();
  final _payloadController = TextEditingController();

  bool _notificationsEnabled = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<int> _insertCompanyData() async {
    if (_companyNameController.text.isNotEmpty && _selectedDate != null && _selectedTime != null) {
      int notificationId = random.nextInt(2147483647);
      String companyName = _companyNameController.text;
      String payload = _payloadController.text;
      DateTime notificationDt = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour,_selectedTime!.minute);
      int insertedCompanyId =
          await DatabaseHelper().insertCompany(companyName, notificationDt!, notificationId);

      _companyNameController.clear();
      _payloadController.clear();

      setState(() {
        _selectedDate = null;
        _selectedTime = null;

      });

      if(insertedCompanyId == -1){
        return -1;
      }

      if(_notificationsEnabled) {
        bool notificationStatus = await NotificationService().
        scheduleNotification(
            id: notificationId,
            title: 'Trading Reminder',
            body: '$companyName have result day today! $payload',
            payLoad: payload,
            scheduledNotificationDt: notificationDt
        );

        if(notificationStatus){
          return 1;
        }
      }

      return 2;
    }
    else {
      return 0;
    }
  }

  Widget getAlertMessage(int insertionStatus){
    if(_notificationsEnabled && (insertionStatus == 1)){
      return const Text('Company Added and Notification Set!', style: TextStyle(fontSize: 16));
    }
    else if (insertionStatus == 2){
      return const Text('Company Added! Notification Overdue', style: TextStyle(fontSize: 16));
    }
    else if (insertionStatus == 1){
      return const Text('Company Added. Notification Permissions denied!', style: TextStyle(fontSize: 16));
    }
    else if (insertionStatus == -1){
      return const Text('Company Already Exists!', style: TextStyle(fontSize: 16));
    }
    else{
      return const Text('Something Went Wrong!', style: TextStyle(fontSize: 16));

    }
  }

  void _insertionAlert(int insertionStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            title: getAlertMessage(insertionStatus),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              ),
            ],
          );
      },
    );
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await NotificationService().flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await NotificationService().flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await NotificationService().flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      NotificationService().flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
      await androidImplementation?.requestPermission();
      await androidImplementation?.createNotificationChannel(const AndroidNotificationChannel(
          'tradingReminderChannelId',
          'tradingReminderChannel',
          importance: Importance.max,
          playSound: true,
          enableVibration: true
      ));
      setState(() {
        _notificationsEnabled = grantedNotificationPermission ?? false;
      });
    }
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final formattedTime = DateFormat.jm().format(dateTime);
    return formattedTime;
  }

  @override
  void initState() {
    _isAndroidPermissionGranted();
    _requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _companyNameController,
            style: const TextStyle(color: Colors.blueGrey),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white70,
              focusColor: Colors.black26,
              hintText: 'Company Name',
              hintStyle: TextStyle(color: Colors.blueGrey),
              prefixIcon: Icon(
                Icons.add_business,
                color: Colors.blueGrey,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.blueGrey,
                  textStyle: const TextStyle(fontSize: 16,)
              ),
              child: Text(_selectedDate != null
                  ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'
                  : 'Select Notification Date'),
            ),
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.blueGrey,
                  textStyle: const TextStyle(fontSize: 16,)
              ),
              onPressed: ()  => _selectTime(context),
                child: Text(_selectedTime != null
                    ? 'Selected Time: ${formatTimeOfDay(_selectedTime!)}'
                    : 'Select Notification Time'),
            ),
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            height: 60,
            child: TextField(
              controller: _payloadController,
              style: const TextStyle(color: Colors.blueGrey),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white70,
                hintText: 'Notification Message',
                hintStyle: TextStyle(color: Colors.blueGrey),
                prefixIcon: Icon(
                  Icons.message,
                  color: Colors.blueGrey,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 75.0),
          SizedBox(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.blueGrey,
                  textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.w700),
              ),
              onPressed: () async {

                int insertStatus = await _insertCompanyData();
                _insertionAlert(insertStatus);

              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the icon and text horizontally
                children: [
                  Icon(Icons.add_box_outlined), // Add your desired icon here
                  SizedBox(width: 8.0), // Add a small space between the icon and text
                  Text('Insert Company Data'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
