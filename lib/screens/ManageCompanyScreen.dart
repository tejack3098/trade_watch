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

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final TextEditingController _companyNameController = TextEditingController();
  DateTime? _selectedDate;

  void _selectDate(BuildContext context) async {
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

  Future<bool> _insertCompanyData() async {
    if (_companyNameController.text.isNotEmpty && _selectedDate != null) {
      String companyName = _companyNameController.text;
      int insertedCompanyId =
          await DatabaseHelper().insertCompany(companyName, _selectedDate!);

      _companyNameController.clear();

      setState(() {
        _selectedDate = null;
      });

      return true;
    }
    else {
      return false;
    }
  }

  void _insertionAlert(bool insertionStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            title:  insertionStatus ? const Text('Company Added') : const Text('Something Went Wrong'),
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

  @override
  Widget build(BuildContext context) {

    return Padding(
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
                  : 'Select Date'),
            ),
          ),
          const SizedBox(height: 100.0),
          SizedBox(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.blueGrey,
                  textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.w700)
              ),
              onPressed: () async {

                bool insertStatus = await _insertCompanyData();
                _insertionAlert(insertStatus);

              },
              child: const Text('Insert Company Data'),
            ),
          ),
        ],
      ),
    );
  }
}
