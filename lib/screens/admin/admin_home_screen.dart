import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/app_theme.dart';
import 'admin_users_screen.dart';
import 'admin_manage_user_screen.dart';
import 'admin_master_data_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<DrawerItem> _drawerItems = [
    DrawerItem(
      title: 'Users',
      icon: Icons.people,
      route: '/admin/users',
    ),
    DrawerItem(
      title: 'Manage User',
      icon: Icons.person,
      route: '/admin/manage-user',
    ),
    DrawerItem(
      title: 'Master Data',
      icon: Icons.database,
      route: '/admin/master-data',
    ),
  ];

  final List<Widget> _screens = [
    const AdminUsersScreen(),
    const AdminManageUserScreen(),
    const AdminMasterDataScreen(),
  ];

  void _onDrawerItemTap(String route) {
    setState(() {
      switch (route) {
        case '/admin/users':
          _currentIndex = 0;
          break;
        case '/admin/manage-user':
          _currentIndex = 1;
          break;
        case '/admin/master-data':
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