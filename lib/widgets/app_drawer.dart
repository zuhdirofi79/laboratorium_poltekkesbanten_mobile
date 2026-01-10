import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_state_provider.dart';
import '../utils/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final List<DrawerItem> items;
  final String currentRoute;
  final Function(String) onItemTap;

  const AppDrawer({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poltekkes Logo
                Image.asset(
                  'assets/img/logo/poltekkeskemenkesbanten-logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.science,
                      size: 50,
                      color: Colors.white,
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'SiLab',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.fullName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (user?.email != null && user!.email.isNotEmpty)
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = currentRoute == item.route;

                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                  ),
                  title: Text(item.title),
                  selected: isSelected,
                  selectedTileColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  onTap: () {
                    Navigator.pop(context);
                    onItemTap(item.route);
                  },
                  trailing: item.badge != null && item.badge! > 0
                      ? Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${item.badge}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Ubah Password'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to change password
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await authProvider.logout();
                // Navigation is handled automatically by AuthWrapper based on AuthState
              }
            },
          ),
          const Divider(),
          // BLU Speed Logo (footer)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/img/logo/logo-blu-speed.png',
              width: 100,
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class DrawerItem {
  final String title;
  final IconData icon;
  final String route;
  final int? badge;

  DrawerItem({
    required this.title,
    required this.icon,
    required this.route,
    this.badge,
  });
}