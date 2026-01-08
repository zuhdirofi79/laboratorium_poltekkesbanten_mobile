import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/equipment_request_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';
import 'user_create_request_screen.dart';

class UserRequestPeralatanScreen extends StatefulWidget {
  const UserRequestPeralatanScreen({super.key});

  @override
  State<UserRequestPeralatanScreen> createState() => _UserRequestPeralatanScreenState();
}

class _UserRequestPeralatanScreenState extends State<UserRequestPeralatanScreen> {
  final ApiService _apiService = ApiService();
  List<EquipmentRequestModel> _requests = [];
  List<EquipmentRequestModel> _filteredRequests = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final requests = await _apiService.getUserRequestPeralatan();
      setState(() {
        _requests = requests;
        _filteredRequests = requests;
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

  void _filterRequests(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredRequests = _requests;
      } else {
        _filteredRequests = _requests.where((request) {
          return request.jenisAlat.toLowerCase().contains(query.toLowerCase()) ||
              request.ruangLab.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'menunggu konfirmasi':
        return AppTheme.statusPending;
      case 'approved':
      case 'disetujui':
        return AppTheme.statusApproved;
      case 'rejected':
      case 'ditolak':
        return AppTheme.statusRejected;
      default:
        return AppTheme.textSecondary;
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
                  onSearch: _filterRequests,
                  hintText: 'Cari request...',
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserCreateRequestScreen()),
                  );
                  if (result == true) {
                    _loadRequests();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Formulir Peminjaman Alat'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredRequests.isEmpty
                  ? const Center(child: Text('Tidak ada data'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredRequests.length,
                      itemBuilder: (context, index) {
                        final request = _filteredRequests[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.request_quote, color: AppTheme.primaryColor),
                            title: Text(request.jenisAlat),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ruang Lab: ${request.ruangLab}'),
                                Text('Tingkat: ${request.tingkat}'),
                                Text('Tanggal: ${DateFormat('dd MMM yyyy').format(request.tglPermintaan)}'),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(request.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                request.statusLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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