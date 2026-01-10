import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../features/plp_approval/presentation/plp_approval_provider.dart';
import '../../features/plp_approval/presentation/plp_approval_state.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/error_code.dart';
import '../../utils/app_theme.dart';

class PLPRequestDetailScreen extends StatefulWidget {
  final int requestId;

  const PLPRequestDetailScreen({super.key, required this.requestId});

  @override
  State<PLPRequestDetailScreen> createState() => _PLPRequestDetailScreenState();
}

class _PLPRequestDetailScreenState extends State<PLPRequestDetailScreen> {
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load request detail when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PlpApprovalProvider>(context, listen: false);
      provider.loadRequestDetail(widget.requestId);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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

  Future<void> _approveRequest(PlpApprovalProvider provider) async {
    await provider.approveRequest(widget.requestId);
    
    // Handle action success - navigation handled by state
    if (mounted) {
      final state = provider.state;
      if (state is PlpApprovalActionSuccess) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _rejectRequest(PlpApprovalProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Alasan penolakan:'),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(hintText: 'Masukkan alasan'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final reason = _reasonController.text.trim();
      if (reason.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alasan penolakan wajib diisi'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      await provider.rejectRequest(widget.requestId, reason);
      
      // Handle action success - navigation handled by state
      if (mounted) {
        final state = provider.state;
        if (state is PlpApprovalActionSuccess) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Request')),
      body: Consumer<PlpApprovalProvider>(
        builder: (context, provider, child) {
          final state = provider.state;

          // Handle action success - close screen after approve/reject
          if (state is PlpApprovalActionSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                Navigator.pop(context);
              }
            });
          }

          return _buildStateContent(state, provider);
        },
      ),
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
              onPressed: () => provider.loadRequestDetail(widget.requestId),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is PlpApprovalDetailLoaded) {
      final detail = state.detail;
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Nama Peminjam', detail.userName),
                    const Divider(),
                    _buildDetailRow('Username', detail.userUsername),
                    const Divider(),
                    _buildDetailRow('Jenis Alat', detail.itemName),
                    const Divider(),
                    _buildDetailRow('Ruang Lab', detail.labRoom),
                    if (detail.level != null) ...[
                      const Divider(),
                      _buildDetailRow('Tingkat', detail.level!),
                    ],
                    const Divider(),
                    _buildDetailRow('Tanggal Permintaan', DateFormat('dd MMM yyyy').format(detail.requestDate)),
                    if (detail.purpose != null) ...[
                      const Divider(),
                      _buildDetailRow('Tujuan', detail.purpose!),
                    ],
                    if (detail.startTime != null && detail.endTime != null) ...[
                      const Divider(),
                      _buildDetailRow('Waktu', '${detail.startTime} - ${detail.endTime}'),
                    ],
                    if (detail.items.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Item Peralatan:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ...detail.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Text('• '),
                                Expanded(
                                  child: Text('${item.itemName} (${item.stockQuantity}x)'),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (detail.canApproveOrReject)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () => _rejectRequest(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () => _approveRequest(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                      ),
                      child: const Text('Setujui'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    }

    if (state is PlpApprovalActionSuccess) {
      // Show loading while closing screen
      return const Center(child: CircularProgressIndicator());
    }

    // Initial state or other states
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}