import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class PLPRequestDetailScreen extends StatefulWidget {
  final int requestId;

  const PLPRequestDetailScreen({super.key, required this.requestId});

  @override
  State<PLPRequestDetailScreen> createState() => _PLPRequestDetailScreenState();
}

class _PLPRequestDetailScreenState extends State<PLPRequestDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _requestData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequestDetail();
  }

  Future<void> _loadRequestDetail() async {
    try {
      final data = await _apiService.getRequestDetail(widget.requestId);
      setState(() {
        _requestData = data;
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

  Future<void> _approveRequest() async {
    try {
      await _apiService.approveRequest(widget.requestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request disetujui')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _rejectRequest() async {
    final reasonController = TextEditingController();
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
              controller: reasonController,
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

    if (confirm == true) {
      try {
        await _apiService.rejectRequest(widget.requestId, reason: reasonController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request ditolak')),
          );
          Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Request')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requestData == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
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
                              _buildDetailRow('Nama Peminjam', _requestData!['nama_peminjam'] ?? ''),
                              const Divider(),
                              _buildDetailRow('Jenis Alat', _requestData!['jenis_alat'] ?? ''),
                              const Divider(),
                              _buildDetailRow('Ruang Lab', _requestData!['ruang_lab'] ?? ''),
                              const Divider(),
                              _buildDetailRow('Tingkat', _requestData!['tingkat'] ?? ''),
                              const Divider(),
                              _buildDetailRow('Tanggal Permintaan', _requestData!['tgl_permintaan'] ?? ''),
                              if (_requestData!['keterangan'] != null) ...[
                                const Divider(),
                                _buildDetailRow('Keterangan', _requestData!['keterangan'] ?? ''),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_requestData!['status']?.toLowerCase() == 'pending' ||
                          _requestData!['status']?.toLowerCase() == 'menunggu konfirmasi')
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _rejectRequest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.errorColor,
                                ),
                                child: const Text('Tolak'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _approveRequest,
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
                ),
    );
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