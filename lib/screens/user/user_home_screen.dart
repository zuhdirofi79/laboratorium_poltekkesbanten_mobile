import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import 'user_request_peralatan_screen.dart';
import 'user_jadwal_praktikum_screen.dart';
import 'user_kunjungan_lab_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;

  final List<DrawerItem> _drawerItems = [
    DrawerItem(
      title: 'Request Peralatan',
      icon: Icons.request_quote,
      route: '/user/request-peralatan',
    ),
    DrawerItem(
      title: 'Jadwal Praktikum',
      icon: Icons.calendar_today,
      route: '/user/jadwal-praktikum',
    ),
    DrawerItem(
      title: 'Kunjungan Lab',
      icon: Icons.science,
      route: '/user/kunjungan-lab',
    ),
  ];

  final List<Widget> _screens = [
    const UserRequestPeralatanScreen(),
    const UserJadwalPraktikumScreen(),
    const UserKunjunganLabScreen(),
  ];

  void _onDrawerItemTap(String route) {
    setState(() {
      switch (route) {
        case '/user/request-peralatan':
          _currentIndex = 0;
          break;
        case '/user/jadwal-praktikum':
          _currentIndex = 1;
          break;
        case '/user/kunjungan-lab':
          _currentIndex = 2;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_drawerItems[_currentIndex].title),
      ),
      drawer: AppDrawer(
        items: _drawerItems,
        currentRoute: _drawerItems[_currentIndex].route,
        onItemTap: _onDrawerItemTap,
      ),
      body: _screens[_currentIndex],
    );
  }
}