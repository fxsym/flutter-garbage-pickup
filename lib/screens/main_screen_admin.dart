import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_admin_page.dart';
import 'aktivitas_admin_page.dart';
import 'profile_page.dart';

class MainScreenAdmin extends StatefulWidget {
  final int initialIndex;

  MainScreenAdmin({this.initialIndex = 0}); // default tetap dashboard

  @override
  _MainScreenAdminState createState() => _MainScreenAdminState();
}

class _MainScreenAdminState extends State<MainScreenAdmin> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // ambil dari parameter
  }

  final List<Widget> _pages = [
    DashboardAdminPage(),
    AktivitasAdminPage(),
    ProfilePage(),
  ];

  final List<String> _titles = [
    'Dashboard Admin',
    'Aktivitas Admin',
    'Profil',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true, // Biar teksnya di tengah
        title: Row(
          children: [
            Image.asset(
              'assets/images/Logo.png',
              width: MediaQuery.of(context).size.width * 0.1,
              fit: BoxFit.cover,
            ),
            const Text(
              'WasteChange',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.purple[200],
        elevation: 4,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.purple[800],
        unselectedItemColor: Colors.purple,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Aktivitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
