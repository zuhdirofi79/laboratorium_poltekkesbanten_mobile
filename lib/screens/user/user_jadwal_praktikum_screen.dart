import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../features/schedule/presentation/schedule_provider.dart';
import '../../features/schedule/presentation/schedule_state.dart';
import '../../features/schedule/domain/praktikum_schedule.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/error_code.dart';
import '../../utils/app_theme.dart';
import '../../widgets/search_bar_widget.dart';

class UserJadwalPraktikumScreen extends StatefulWidget {
  const UserJadwalPraktikumScreen({super.key});

  @override
  State<UserJadwalPraktikumScreen> createState() => _UserJadwalPraktikumScreenState();
}

class _UserJadwalPraktikumScreenState extends State<UserJadwalPraktikumScreen> {
  String _searchQuery = '';
  List<PraktikumSchedule> _filteredSchedules = [];

  @override
  void initState() {
    super.initState();
    // Load schedules when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ScheduleProvider>(context, listen: false);
      if (provider.state is ScheduleInitial) {
        provider.loadSchedules();
      }
    });
  }

  void _filterSchedules(String query, List<PraktikumSchedule> schedules) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSchedules = schedules;
      } else {
        _filteredSchedules = schedules.where((schedule) {
          return schedule.mataKuliah.toLowerCase().contains(query.toLowerCase()) ||
              schedule.ruangLab.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
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
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        final state = provider.state;

        // Initialize/update filtered schedules when state changes to Loaded
        if (state is ScheduleLoaded) {
          final schedules = state.schedules;
          if (_filteredSchedules.isEmpty && schedules.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _filterSchedules('', schedules);
              }
            });
          } else if (_filteredSchedules.length != schedules.length) {
            _filterSchedules(_searchQuery, schedules);
          }
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBarWidget(
                onSearch: (query) {
                  if (state is ScheduleLoaded) {
                    _filterSchedules(query, state.schedules);
                  }
                },
                hintText: 'Cari jadwal...',
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

  Widget _buildStateContent(ScheduleState state, ScheduleProvider provider) {
    if (state is ScheduleLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ScheduleError) {
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
              onPressed: () => provider.loadSchedules(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is ScheduleEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'Tidak ada jadwal praktikum',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state is ScheduleLoaded) {
      final schedules = state.schedules;
      final schedulesToShow = _searchQuery.isEmpty
          ? schedules
          : _filteredSchedules.isEmpty
              ? schedules
              : _filteredSchedules;

      if (schedulesToShow.isEmpty) {
        return const Center(
          child: Text('Tidak ada data yang cocok dengan pencarian'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: schedulesToShow.length,
        itemBuilder: (context, index) {
          final schedule = schedulesToShow[index];
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