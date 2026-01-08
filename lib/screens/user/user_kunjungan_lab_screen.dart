import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class UserKunjunganLabScreen extends StatefulWidget {
  const UserKunjunganLabScreen({super.key});

  @override
  State<UserKunjunganLabScreen> createState() => _UserKunjunganLabScreenState();
}

class _UserKunjunganLabScreenState extends State<UserKunjunganLabScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _visits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final visits = await _apiService.getUserKunjunganLab();
      setState(() {
        _visits = visits;
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

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _visits.isEmpty
            ? const Center(child: Text('Tidak ada data'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _visits.length,
                itemBuilder: (context, index) {
                  final visit = _visits[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.science, color: AppTheme.primaryColor),
                      title: Text(visit['ruang_lab'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal: ${visit['tanggal'] ?? ''}'),
                          Text('Waktu: ${visit['waktu'] ?? ''}'),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}