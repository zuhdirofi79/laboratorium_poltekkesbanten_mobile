import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/praktikum_schedule_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';

class PLPJadwalPraktikumScreen extends StatefulWidget {
  const PLPJadwalPraktikumScreen({super.key});

  @override
  State<PLPJadwalPraktikumScreen> createState() => _PLPJadwalPraktikumScreenState();
}

class _PLPJadwalPraktikumScreenState extends State<PLPJadwalPraktikumScreen> {
  final ApiService _apiService = ApiService();
  List<PraktikumScheduleModel> _schedules = [];
  List<PraktikumScheduleModel> _filteredSchedules = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final schedules = await _apiService.getJadwalPraktikum(search: _searchQuery.isNotEmpty ? _searchQuery : null);
      setState(() {
        _schedules = schedules;
        _filteredSchedules = schedules;
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

  void _filterSchedules(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSchedules = _schedules;
      } else {
        _filteredSchedules = _schedules.where((schedule) {
          return schedule.mataKuliah.toLowerCase().contains(query.toLowerCase()) ||
              schedule.ruangLab.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchBarWidget(
            onSearch: _filterSchedules,
            hintText: 'Cari jadwal...',
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredSchedules.isEmpty
                  ? const Center(child: Text('Tidak ada data'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredSchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = _filteredSchedules[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                            title: Text(schedule.mataKuliah),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Kelas: ${schedule.kelas}'),
                                Text('Ruang: ${schedule.ruangLab}'),
                                Text('Tanggal: ${DateFormat('dd MMM yyyy').format(schedule.tanggal)}'),
                                Text('Waktu: ${schedule.jamMulai} - ${schedule.jamSelesai}'),
                                if (schedule.dosen != null) Text('Dosen: ${schedule.dosen}'),
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