import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/app_theme.dart';
import '../../providers/auth_state_provider.dart';
import '../../features/auth/data/auth_models.dart';
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
    return Consumer<AuthStateProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        // Verify role - block access if role mismatch
        if (user == null || !user.role.isAdmin) {
          // Role mismatch or not authenticated - redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Akses ditolak: Hanya admin yang dapat mengakses halaman ini'),
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

        // Role verified - show admin content
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
      },
    );
  }
}