import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../features/equipment/presentation/equipment_provider.dart';
import '../../features/equipment/presentation/equipment_state.dart';
import '../../features/equipment/domain/equipment_request.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/error_code.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';
import 'user_create_request_screen.dart';

class UserRequestPeralatanScreen extends StatefulWidget {
  const UserRequestPeralatanScreen({super.key});

  @override
  State<UserRequestPeralatanScreen> createState() => _UserRequestPeralatanScreenState();
}

class _UserRequestPeralatanScreenState extends State<UserRequestPeralatanScreen> {
  String _searchQuery = '';
  List<EquipmentRequest> _filteredRequests = [];

  @override
  void initState() {
    super.initState();
    // Load requests when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EquipmentProvider>(context, listen: false);
      if (provider.state is EquipmentInitial) {
        provider.loadRequests();
      }
    });
  }

  void _filterRequests(String query, List<EquipmentRequest> requests) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredRequests = requests;
      } else {
        _filteredRequests = requests.where((request) {
          return request.itemName.toLowerCase().contains(query.toLowerCase()) ||
              request.labRoom.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'menunggu konfirmasi':
      case 'menunggu':
        return AppTheme.statusPending;
      case 'approved':
      case 'disetujui':
      case 'selesai':
        return AppTheme.statusApproved;
      case 'rejected':
      case 'ditolak':
        return AppTheme.statusRejected;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getErrorMessage(Failure failure) {
    // Use error_code for UI decisions, not string comparison
    // Check Failure type first
    if (failure is NetworkFailure) {
      return 'Tidak ada koneksi internet. Silakan periksa koneksi Anda.';
    }

    // Then check error_code for other failures
    switch (failure.errorCode) {
      case ErrorCode.authInvalidToken:
      case ErrorCode.authTokenExpired:
        // AuthWrapper will handle redirect to Login
        return 'Sesi telah berakhir. Anda akan dialihkan ke halaman login.';
      case ErrorCode.reputationBlocked:
      case ErrorCode.ipBlocked:
        // AuthWrapper will handle redirect to SecurityBlockedScreen
        return 'Akses diblokir.';
      case ErrorCode.rateLimited:
        // AuthWrapper will handle redirect to RateLimitScreen
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
    return Consumer<EquipmentProvider>(
      builder: (context, provider, child) {
        final state = provider.state;

        // Initialize/update filtered requests when state changes to Loaded
        if (state is EquipmentLoaded) {
          final requests = state.requests;
          if (_filteredRequests.isEmpty && requests.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _filterRequests('', requests);
              }
            });
          } else if (_filteredRequests.length != requests.length) {
            _filterRequests(_searchQuery, requests);
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
                          if (state is EquipmentLoaded) {
                            _filterRequests(query, state.requests);
                          }
                        },
                        hintText: 'Cari request...',
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: state is EquipmentLoading
                        ? null
                        : () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserCreateRequestScreen(),
                              ),
                            );
                            if (result == true && mounted) {
                              // Reload requests after creating new one
                              provider.loadRequests();
                            }
                          },
                    icon: const Icon(Icons.add),
                    label: const Text('Formulir Peminjaman Alat'),
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

  Widget _buildStateContent(EquipmentState state, EquipmentProvider provider) {
    if (state is EquipmentLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is EquipmentError) {
      final failure = state.failure;

      // Handle auth failures - AuthWrapper will redirect
      if (failure is AuthFailure ||
          failure is SecurityBlockedFailure ||
          failure is RateLimitFailure) {
        // Don't show error UI - AuthWrapper will handle navigation
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
              onPressed: () => provider.loadRequests(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is EquipmentEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'Tidak ada request peralatan',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state is EquipmentLoaded) {
      final requests = state.requests;
      final requestsToShow = _searchQuery.isEmpty
          ? requests
          : _filteredRequests.isEmpty
              ? requests
              : _filteredRequests;

      if (requestsToShow.isEmpty) {
        return const Center(
          child: Text('Tidak ada data yang cocok dengan pencarian'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: requestsToShow.length,
        itemBuilder: (context, index) {
          final request = requestsToShow[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.request_quote, color: AppTheme.primaryColor),
              title: Text(request.itemName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ruang Lab: ${request.labRoom}'),
                  if (request.level != null) Text('Tingkat: ${request.level}'),
                  Text('Tanggal: ${DateFormat('dd MMM yyyy').format(request.requestDate)}'),
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
      );
    }

    // Initial state
    return const Center(child: CircularProgressIndicator());
  }
}