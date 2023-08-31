import 'package:flutter/material.dart';
import 'package:TradeWatch/utils/DatabaseHelper.dart';
import 'package:intl/intl.dart';

class FilterByDateScreen extends StatefulWidget {
  const FilterByDateScreen({super.key});

  @override
  State<FilterByDateScreen> createState() => _FilterByDateScreenState();
}

class _FilterByDateScreenState extends State<FilterByDateScreen> {

  DateTime? _selectedDate;
  DateTime currentDate = DateTime.now();
  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _filteredCompanies = [];

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _filterCompaniesByDate();
      });
    }
  }

  void _filterCompaniesByDate() {
    if (_selectedDate == null) {
      _filteredCompanies = List.from(_companies);
      _sortFilteredCompaniesFromCurrentDate();
    } else {
      _filteredCompanies = _companies
          .where((company) =>
      company['date'] == _selectedDate.toString().substring(0, 10))
          .toList();
      _sortFilteredCompanies();
    }
  }

  void _sortFilteredCompaniesFromCurrentDate(){
    _filteredCompanies = _filteredCompanies.where((company) {
      DateTime companyDate = DateTime.parse(company['date']);
      return companyDate.isAfter(currentDate.subtract(const Duration(days:1)));
    }).toList();

    _filteredCompanies.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
  }

  void _sortFilteredCompanies(){
    _filteredCompanies.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
  }

  void _deleteCompany(String companyName) async {
    await _databaseHelper.deleteCompany(companyName);
    setState(() {
      _companies.removeWhere((company) => company['company_name'] == companyName);
      _filterCompaniesByDate();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCompaniesFromDatabase();
  }

  void _loadCompaniesFromDatabase() async {
    List<Map<String, dynamic>> companies =
    await _databaseHelper.getAllCompanies();
    setState(() {
      _companies = companies;
      _filterCompaniesByDate(); // Update the filtered list after loading data
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedDate == null) {
      // Set the initial filtered list to be the complete list
      _filteredCompanies = List.from(_companies);
      _sortFilteredCompaniesFromCurrentDate();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          child: SizedBox(
            height: 60.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white70, // Change the button color
              ),
              onPressed: _selectDate,
              child: Text(
                _selectedDate != null
                    ? 'Selected Date: ${_selectedDate.toString().substring(0, 10)}'
                    : 'Select Date',
                style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
              color: Colors.blueGrey,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount:_filteredCompanies.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(_filteredCompanies[index]['company_name']), // Use a unique key
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16.0),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _deleteCompany(_filteredCompanies[index]['company_name']);
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ), // Add bottom border
                        ),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _filteredCompanies[index]['company_name']!,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(width: 10), // Add spacing between title and subtitle
                                Text(
                                  ' ${DateFormat('y MMM d hh:mm a').format(DateTime.parse(_filteredCompanies[index]['date']))}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
              )
          ),
        ),
      ],
    );
  }
}

