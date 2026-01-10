import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/admin_rooms/presentation/admin_rooms_provider.dart';
import '../../features/admin_rooms/presentation/admin_rooms_state.dart';
import '../../features/admin_rooms/domain/lab_room.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/error_code.dart';
import '../../utils/app_theme.dart';

class AdminEditRoomScreen extends StatefulWidget {
  final LabRoom room;

  const AdminEditRoomScreen({super.key, required this.room});

  @override
  State<AdminEditRoomScreen> createState() => _AdminEditRoomScreenState();
}

class _AdminEditRoomScreenState extends State<AdminEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaRuangController;
  late TextEditingController _jurusanController;
  late TextEditingController _kampusController;

  @override
  void initState() {
    super.initState();
    _namaRuangController = TextEditingController(text: widget.room.labName);
    _jurusanController = TextEditingController(text: widget.room.department);
    _kampusController = TextEditingController(text: widget.room.campus);
  }

  @override
  void dispose() {
    _namaRuangController.dispose();
    _jurusanController.dispose();
    _kampusController.dispose();
    super.dispose();
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

  Future<void> _submitForm(AdminRoomsProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await provider.updateRoom(
      id: widget.room.id,
      labName: _namaRuangController.text.trim(),
      department: _jurusanController.text.trim(),
      campus: _kampusController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminRoomsProvider>(
      builder: (context, provider, child) {
        final state = provider.state;

        // Handle ActionSuccess - navigate back
        if (state is AdminRoomsActionSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              Navigator.pop(context, true);
            }
          });
        }

        // Handle Error - show message
        if (state is AdminRoomsError) {
          final failure = state.failure;
          if (!(failure is AuthFailure ||
              failure is SecurityBlockedFailure ||
              failure is RateLimitFailure)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_getErrorMessage(failure)),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            });
          }
        }

        final isLoading = state is AdminRoomsLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Edit Ruangan')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _namaRuangController,
                    decoration: const InputDecoration(labelText: 'Nama Ruang Lab'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama ruang lab tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _jurusanController,
                    decoration: const InputDecoration(labelText: 'Jurusan'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jurusan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _kampusController,
                    decoration: const InputDecoration(labelText: 'Kampus'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kampus tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _submitForm(provider),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}