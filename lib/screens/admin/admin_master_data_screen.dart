import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/admin_rooms/presentation/admin_rooms_provider.dart';
import '../../features/admin_rooms/presentation/admin_rooms_state.dart';
import '../../features/admin_rooms/domain/lab_room.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/error_code.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';
import 'admin_add_room_screen.dart';
import 'admin_edit_room_screen.dart';

class AdminMasterDataScreen extends StatefulWidget {
  const AdminMasterDataScreen({super.key});

  @override
  State<AdminMasterDataScreen> createState() => _AdminMasterDataScreenState();
}

class _AdminMasterDataScreenState extends State<AdminMasterDataScreen> {
  String _searchQuery = '';
  List<LabRoom> _filteredRooms = [];

  @override
  void initState() {
    super.initState();
    // Load rooms when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminRoomsProvider>(context, listen: false);
      final state = provider.state;
      if (state is AdminRoomsInitial) {
        provider.loadRooms();
      }
    });
  }

  void _filterRooms(String query, List<LabRoom> rooms) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredRooms = rooms;
      } else {
        _filteredRooms = rooms.where((room) {
          return room.labName.toLowerCase().contains(query.toLowerCase()) ||
              room.department.toLowerCase().contains(query.toLowerCase()) ||
              room.campus.toLowerCase().contains(query.toLowerCase());
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
    return Consumer<AdminRoomsProvider>(
      builder: (context, provider, child) {
        final state = provider.state;

        // Handle ActionSuccess - reload list and show message
        if (state is AdminRoomsActionSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              provider.loadRooms();
            }
          });
        }

        // Initialize/update filtered rooms when state changes to Loaded
        if (state is AdminRoomsLoaded) {
          final rooms = state.rooms;
          if (_filteredRooms.isEmpty && rooms.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _filterRooms('', rooms);
              }
            });
          } else if (_filteredRooms.length != rooms.length) {
            _filterRooms(_searchQuery, rooms);
          }
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBarWidget(
                      onSearch: (query) {
                        if (state is AdminRoomsLoaded) {
                          _filterRooms(query, state.rooms);
                        } else {
                          provider.loadRooms(search: query);
                        }
                      },
                      hintText: 'Cari ruangan...',
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: state is AdminRoomsLoading
                        ? null
                        : () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminAddRoomScreen(),
                              ),
                            );
                            if (result == true && mounted) {
                              provider.loadRooms();
                            }
                          },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Ruangan'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildStateContent(state, provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStateContent(AdminRoomsState state, AdminRoomsProvider provider) {
    if (state is AdminRoomsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AdminRoomsError) {
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
            Icon(
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
              onPressed: () => provider.loadRooms(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is AdminRoomsEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.room_outlined, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'Tidak ada data ruangan',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state is AdminRoomsLoaded) {
      final rooms = state.rooms;
      final roomsToShow = _searchQuery.isEmpty
          ? rooms
          : _filteredRooms.isEmpty
              ? rooms
              : _filteredRooms;

      if (roomsToShow.isEmpty) {
        return const Center(
          child: Text('Tidak ada data yang cocok dengan pencarian'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: roomsToShow.length,
        itemBuilder: (context, index) {
          final room = roomsToShow[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.room, color: AppTheme.primaryColor),
              title: Text(room.labName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jurusan: ${room.department}'),
                  Text('Kampus: ${room.campus}'),
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
                          builder: (context) => AdminEditRoomScreen(room: room),
                        ),
                      );
                      if (result == true && mounted) {
                        provider.loadRooms();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hapus Ruangan'),
                          content: Text('Apakah Anda yakin ingin menghapus ruangan ${room.labName}?'),
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
                        provider.deleteRoom(room.id);
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