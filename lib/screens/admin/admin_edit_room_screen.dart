import 'package:flutter/material.dart';
import '../../models/lab_room_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class AdminEditRoomScreen extends StatefulWidget {
  final LabRoomModel room;

  const AdminEditRoomScreen({super.key, required this.room});

  @override
  State<AdminEditRoomScreen> createState() => _AdminEditRoomScreenState();
}

class _AdminEditRoomScreenState extends State<AdminEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaRuangController;
  late TextEditingController _jurusanController;
  late TextEditingController _kampusController;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaRuangController = TextEditingController(text: widget.room.namaRuangLab);
    _jurusanController = TextEditingController(text: widget.room.jurusan);
    _kampusController = TextEditingController(text: widget.room.kampus);
  }

  @override
  void dispose() {
    _namaRuangController.dispose();
    _jurusanController.dispose();
    _kampusController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.editRoom(widget.room.id!, {
        'nama_ruang_lab': _namaRuangController.text.trim(),
        'jurusan': _jurusanController.text.trim(),
        'kampus': _kampusController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruangan berhasil diupdate')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
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
  }
}