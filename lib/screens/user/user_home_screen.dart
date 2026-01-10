import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_drawer.dart';
import '../../providers/auth_state_provider.dart';
import '../../utils/app_theme.dart';
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
    return Consumer<AuthStateProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        // Verify role - block access if role mismatch
        if (user == null || !user.role.isUser) {
          // Role mismatch or not authenticated - redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Akses ditolak: Hanya user yang dapat mengakses halaman ini'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
              Navigator.of(context).pushReplacementNamed('/login');
            }
          });
          
          return Scaffold(
            appBar: AppBar(title: const Text('Akses Ditolak')),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Role verified - show user content
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SiLab',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _drawerItems[_currentIndex].title,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          drawer: AppDrawer(
            items: _drawerItems,
            currentRoute: _drawerItems[_currentIndex].route,
            onItemTap: _onDrawerItemTap,
          ),
          body: _screens[_currentIndex],
        );
      },
    );
  }
}