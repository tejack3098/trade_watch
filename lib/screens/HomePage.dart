import 'package:flutter/material.dart';
import 'CompaniesScreen.dart';
import 'FilterByDateScreen.dart';
import 'ManageCompanyScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CompaniesScreen(),
    const FilterByDateScreen(),
    const ManageCompanyScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          title: const Center(child: Text('Trading Reminder')),
            backgroundColor: Colors.black26,
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white70,
          selectedItemColor: Colors.teal,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Companies'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'By Date'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_box),
                label: 'Add Company'
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}