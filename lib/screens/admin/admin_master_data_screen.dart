import 'package:flutter/material.dart';
import '../../models/lab_room_model.dart';
import '../../services/api_service.dart';
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
  final ApiService _apiService = ApiService();
  List<LabRoomModel> _rooms = [];
  List<LabRoomModel> _filteredRooms = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rooms = await _apiService.getMasterData(search: _searchQuery.isNotEmpty ? _searchQuery : null);
      setState(() {
        _rooms = rooms;
        _filteredRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _filterRooms(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredRooms = _rooms;
      } else {
        _filteredRooms = _rooms.where((room) {
          return room.namaRuangLab.toLowerCase().contains(query.toLowerCase()) ||
              room.jurusan.toLowerCase().contains(query.toLowerCase()) ||
              room.kampus.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _deleteRoom(int id, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Ruangan'),
        content: Text('Apakah Anda yakin ingin menghapus ruangan $nama?'),
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

    if (confirm == true) {
      try {
        await _apiService.deleteRoom(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ruangan berhasil dihapus')),
          );
          _loadRooms();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SearchBarWidget(
                  onSearch: _filterRooms,
                  hintText: 'Cari ruangan...',
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminAddRoomScreen()),
                  );
                  if (result == true) {
                    _loadRooms();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Ruangan'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredRooms.isEmpty
                  ? const Center(child: Text('Tidak ada data'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredRooms.length,
                      itemBuilder: (context, index) {
                        final room = _filteredRooms[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.room, color: AppTheme.primaryColor),
                            title: Text(room.namaRuangLab),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Jurusan: ${room.jurusan}'),
                                Text('Kampus: ${room.kampus}'),
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
                                    if (result == true) {
                                      _loadRooms();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                                  onPressed: () => _deleteRoom(room.id!, room.namaRuangLab),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}