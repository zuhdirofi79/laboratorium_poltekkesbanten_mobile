import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class AdminAddRoomScreen extends StatefulWidget {
  const AdminAddRoomScreen({super.key});

  @override
  State<AdminAddRoomScreen> createState() => _AdminAddRoomScreenState();
}

class _AdminAddRoomScreenState extends State<AdminAddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaRuangController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _kampusController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

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
      await _apiService.addRoom({
        'nama_ruang_lab': _namaRuangController.text.trim(),
        'jurusan': _jurusanController.text.trim(),
        'kampus': _kampusController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruangan berhasil ditambahkan')),
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
      appBar: AppBar(title: const Text('Tambah Ruangan')),
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