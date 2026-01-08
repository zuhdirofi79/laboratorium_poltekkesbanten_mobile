import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class UserCreateRequestScreen extends StatefulWidget {
  const UserCreateRequestScreen({super.key});

  @override
  State<UserCreateRequestScreen> createState() => _UserCreateRequestScreenState();
}

class _UserCreateRequestScreenState extends State<UserCreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jenisAlatController = TextEditingController();
  final _ruangLabController = TextEditingController();
  final _tingkatController = TextEditingController();
  final _keteranganController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _jenisAlatController.dispose();
    _ruangLabController.dispose();
    _tingkatController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal permintaan')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.createEquipmentRequest({
        'jenis_alat': _jenisAlatController.text.trim(),
        'ruang_lab': _ruangLabController.text.trim(),
        'tingkat': _tingkatController.text.trim(),
        'tgl_permintaan': _selectedDate!.toIso8601String(),
        'keterangan': _keteranganController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request berhasil dibuat')),
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
      appBar: AppBar(title: const Text('Formulir Peminjaman Alat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _jenisAlatController,
                decoration: const InputDecoration(labelText: 'Jenis Alat'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jenis alat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ruangLabController,
                decoration: const InputDecoration(labelText: 'Ruang Lab'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ruang lab tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tingkatController,
                decoration: const InputDecoration(labelText: 'Tingkat'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tingkat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Tanggal Permintaan'),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Pilih tanggal',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keteranganController,
                decoration: const InputDecoration(labelText: 'Keterangan'),
                maxLines: 3,
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
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}