import 'package:flutter/material.dart';
import 'package:TradeWatch/utils/DatabaseHelper.dart';
import 'package:intl/intl.dart';

class CompaniesScreen extends StatefulWidget  {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {

  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _filteredCompanies = [];

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final searchController = TextEditingController();

  void _filterCompanies(String searchTerm) {
    setState(() {
      if (searchTerm.isEmpty) {
        _filteredCompanies = _companies;
      } else {
        _filteredCompanies = _companies
            .where((company) =>
            company['company_name']!.toLowerCase().contains(searchTerm.toLowerCase()))
            .toList();
      }
    });
  }

  void _loadCompaniesFromDatabase() async {
    List<Map<String, dynamic>> companies =
    await _databaseHelper.getAllCompanies();
    setState(() {
      _companies = companies;
      _filterCompanies(searchController.text);
    });
  }

  void _deleteCompany(String companyName) async {
    await _databaseHelper.deleteCompany(companyName);
    setState(() {
      _companies.removeWhere((company) => company['company_name'] == companyName);
      _filterCompanies(searchController.text);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCompaniesFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            onChanged: _filterCompanies,
            style: const TextStyle(color: Colors.blueGrey),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white70,
              hintText: 'Search Company',
              hintStyle: TextStyle(color: Colors.blueGrey),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.blueGrey,
              ),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: Container(
              color: Colors.blueGrey,
              child: ListView.builder(
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
                          ),
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
                                const SizedBox(width: 10),
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

