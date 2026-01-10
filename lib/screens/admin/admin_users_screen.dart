import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/admin_users/presentation/admin_users_provider.dart';
import '../../features/admin_users/presentation/admin_users_state.dart';
import '../../features/admin_users/domain/admin_user.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/error_code.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';
import 'admin_add_user_screen.dart';
import 'admin_edit_user_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _searchQuery = '';
  List<AdminUser> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    // Load users when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminUsersProvider>(context, listen: false);
      final state = provider.state;
      if (state is AdminUsersInitial) {
        provider.loadUsers();
      }
    });
  }

  void _filterUsers(String query, List<AdminUser> users) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = users;
      } else {
        _filteredUsers = users.where((user) {
          return user.fullName.toLowerCase().contains(query.toLowerCase()) ||
              user.username.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Tidak ada koneksi internet. Silakan periksa koneksi Anda.';
    }

    switch (failure.errorCode) {
      case ErrorCode.authInvalidToken:
      case ErrorCode.authTokenExpired:
        return 'Sesi telah berakhir. Anda akan dialihkan ke halaman login.';
      case ErrorCode.reputationBlocked:
      case ErrorCode.ipBlocked:
        return 'Akses diblokir.';
      case ErrorCode.rateLimited:
        return 'Terlalu banyak permintaan. Silakan tunggu.';
      case ErrorCode.validationError:
        return 'Data tidak valid: ${failure.message}';
      case ErrorCode.resourceNotFound:
        return 'Data tidak ditemukan.';
      case ErrorCode.internalError:
        return 'Kesalahan server. Silakan coba lagi nanti.';
      default:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminUsersProvider>(
      builder: (context, provider, child) {
        final state = provider.state;

        // Handle ActionSuccess - reload list and show message
        if (state is AdminUsersActionSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              provider.loadUsers();
            }
          });
        }

        // Initialize/update filtered users when state changes to Loaded
        if (state is AdminUsersLoaded) {
          final users = state.users;
          if (_filteredUsers.isEmpty && users.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _filterUsers('', users);
              }
            });
          } else if (_filteredUsers.length != users.length) {
            _filterUsers(_searchQuery, users);
          }
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state is AdminUsersLoading
                          ? null
                          : () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminAddUserScreen(),
                                ),
                              );
                              if (result == true && mounted) {
                                provider.loadUsers();
                              }
                            },
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Data'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur import akan ditambahkan')),
                        );
                      },
                      icon: const Icon(Icons.upload),
                      label: const Text('Import Data'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBarWidget(
                onSearch: (query) {
                  if (state is AdminUsersLoaded) {
                    _filterUsers(query, state.users);
                  } else {
                    provider.loadUsers(search: query);
                  }
                },
                hintText: 'Cari user...',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildStateContent(state, provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStateContent(AdminUsersState state, AdminUsersProvider provider) {
    if (state is AdminUsersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AdminUsersError) {
      final failure = state.failure;

      // Handle auth failures - AuthWrapper will redirect
      if (failure is AuthFailure ||
          failure is SecurityBlockedFailure ||
          failure is RateLimitFailure) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // Show error UI for other failures
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              _getErrorMessage(failure),
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.loadUsers(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is AdminUsersEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'Tidak ada data user',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state is AdminUsersLoaded) {
      final users = state.users;
      final usersToShow = _searchQuery.isEmpty
          ? users
          : _filteredUsers.isEmpty
              ? users
              : _filteredUsers;

      if (usersToShow.isEmpty) {
        return const Center(
          child: Text('Tidak ada data yang cocok dengan pencarian'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: usersToShow.length,
        itemBuilder: (context, index) {
          final user = usersToShow[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U'),
              ),
              title: Text(user.fullName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username: ${user.username}'),
                  Text('Email: ${user.email}'),
                  if (user.phone != null && user.phone!.isNotEmpty)
                    Text('Telepon: ${user.phone}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminEditUserScreen(user: user),
                        ),
                      );
                      if (result == true && mounted) {
                        provider.loadUsers();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hapus User'),
                          content: Text('Apakah Anda yakin ingin menghapus user ${user.fullName}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
                        provider.deleteUser(user.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Initial state
    return const Center(child: CircularProgressIndicator());
  }
}