import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import 'plp_daftar_barang_screen.dart';
import 'plp_jadwal_praktikum_screen.dart';
import 'plp_request_peralatan_screen.dart';
import 'plp_request_jadwal_screen.dart';
import 'plp_pinjaman_screen.dart';
import 'plp_laporan_screen.dart';

class PLPHomeScreen extends StatefulWidget {
  const PLPHomeScreen({super.key});

  @override
  State<PLPHomeScreen> createState() => _PLPHomeScreenState();
}

class _PLPHomeScreenState extends State<PLPHomeScreen> {
  int _currentIndex = 0;

  final List<DrawerItem> _drawerItems = [
    DrawerItem(
      title: 'Daftar Barang',
      icon: Icons.inventory,
      route: '/plp/daftar-barang',
    ),
    DrawerItem(
      title: 'Jadwal Praktikum',
      icon: Icons.calendar_today,
      route: '/plp/jadwal-praktikum',
    ),
    DrawerItem(
      title: 'Request Peralatan',
      icon: Icons.request_quote,
      route: '/plp/request-peralatan',
      badge: 2, // This should be dynamic from API
    ),
    DrawerItem(
      title: 'Request Jadwal Praktek',
      icon: Icons.schedule,
      route: '/plp/request-jadwal',
    ),
    DrawerItem(
      title: 'Pinjaman & Pengembalian',
      icon: Icons.swap_horiz,
      route: '/plp/pinjaman',
    ),
    DrawerItem(
      title: 'Laporan',
      icon: Icons.description,
      route: '/plp/laporan',
    ),
  ];

  final List<Widget> _screens = [
    const PLPDaftarBarangScreen(),
    const PLPJadwalPraktikumScreen(),
    const PLPRequestPeralatanScreen(),
    const PLPRequestJadwalScreen(),
    const PLPPinjamanScreen(),
    const PLPLaporanScreen(),
  ];

  void _onDrawerItemTap(String route) {
    setState(() {
      switch (route) {
        case '/plp/daftar-barang':
          _currentIndex = 0;
          break;
        case '/plp/jadwal-praktikum':
          _currentIndex = 1;
          break;
        case '/plp/request-peralatan':
          _currentIndex = 2;
          break;
        case '/plp/request-jadwal':
          _currentIndex = 3;
          break;
        case '/plp/pinjaman':
          _currentIndex = 4;
          break;
        case '/plp/laporan':
          _currentIndex = 5;
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