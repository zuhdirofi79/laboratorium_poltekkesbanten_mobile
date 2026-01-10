import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../features/plp_approval/presentation/plp_approval_provider.dart';
import '../../features/plp_approval/presentation/plp_approval_state.dart';
import '../../features/plp_approval/domain/equipment_request_summary.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/error_code.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';
import 'plp_request_detail_screen.dart';

class PLPRequestPeralatanScreen extends StatefulWidget {
  const PLPRequestPeralatanScreen({super.key});

  @override
  State<PLPRequestPeralatanScreen> createState() => _PLPRequestPeralatanScreenState();
}

class _PLPRequestPeralatanScreenState extends State<PLPRequestPeralatanScreen> {
  String _searchQuery = '';
  String _selectedJurusan = 'all';
  List<EquipmentRequestSummary> _filteredRequests = [];

  @override
  void initState() {
    super.initState();
    // Load pending requests when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PlpApprovalProvider>(context, listen: false);
      if (provider.state is PlpApprovalInitial) {
        provider.loadPendingRequests(status: 'Menunggu');
      }
    });
  }

  void _filterRequests(String query, List<EquipmentRequestSummary> requests) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredRequests = requests;
      } else {
        _filteredRequests = requests.where((request) {
          return request.userName.toLowerCase().contains(query.toLowerCase()) ||
              request.itemName.toLowerCase().contains(query.toLowerCase());
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
      case 'diterima':
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
    return Consumer<PlpApprovalProvider>(
      builder: (context, provider, child) {
        final state = provider.state;

        // Handle action success - reload list after approve/reject
        if (state is PlpApprovalActionSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              // Reload pending requests after action success
              provider.loadPendingRequests(status: 'Menunggu');
            }
          });
        }

        // Initialize/update filtered requests when state changes to ListLoaded
        if (state is PlpApprovalListLoaded) {
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Jurusan'),
                          initialValue: _selectedJurusan,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Semua Jurusan')),
                            DropdownMenuItem(value: 'kebidanan', child: Text('Kebidanan')),
                            DropdownMenuItem(value: 'keperawatan', child: Text('Keperawatan')),
                          ],
                          onChanged: state is PlpApprovalLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedJurusan = value ?? 'all';
                                  });
                                  // Filter by status only - jurusan filter handled by backend
                                  provider.loadPendingRequests(status: 'Menunggu');
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SearchBarWidget(
                    onSearch: (query) {
                      if (state is PlpApprovalListLoaded) {
                        _filterRequests(query, state.requests);
                      }
                    },
                    hintText: 'Cari request...',
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

  Widget _buildStateContent(PlpApprovalState state, PlpApprovalProvider provider) {
    if (state is PlpApprovalLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PlpApprovalError) {
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
              onPressed: () => provider.loadPendingRequests(status: 'Menunggu'),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is PlpApprovalEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'Tidak ada request peralatan menunggu',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state is PlpApprovalListLoaded) {
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
              title: Text(request.userName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jenis Alat: ${request.itemName}'),
                  Text('Ruang Lab: ${request.labRoom}'),
                  if (request.level != null) Text('Tingkat: ${request.level}'),
                  Text('Tanggal: ${DateFormat('dd MMM yyyy').format(request.requestDate)}'),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
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
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PLPRequestDetailScreen(requestId: request.id),
                        ),
                      );
                      // Reload list after returning from detail
                      if (mounted) {
                        provider.loadPendingRequests(status: 'Menunggu');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Detail', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (state is PlpApprovalActionSuccess) {
      // Show loading while reloading after action success
      return const Center(child: CircularProgressIndicator());
    }

    // Initial state
    return const Center(child: CircularProgressIndicator());
  }
}