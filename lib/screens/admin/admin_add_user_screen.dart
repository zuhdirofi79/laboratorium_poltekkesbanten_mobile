import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/admin_users/presentation/admin_users_provider.dart';
import '../../features/admin_users/presentation/admin_users_state.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/error_code.dart';
import '../../utils/app_theme.dart';

class AdminAddUserScreen extends StatefulWidget {
  const AdminAddUserScreen({super.key});

  @override
  State<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends State<AdminAddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;

  @override
  void dispose() {
    _usernameController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
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

  Future<void> _submitForm(AdminUsersProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null || _selectedRole!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role harus dipilih')),
      );
      return;
    }

    await provider.addUser(
      username: _usernameController.text.trim(),
      fullName: _namaController.text.trim(),
      email: _emailController.text.trim(),
      phone: _teleponController.text.trim().isEmpty ? null : _teleponController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminUsersProvider>(
      builder: (context, provider, child) {
        final state = provider.state;

        // Handle ActionSuccess - navigate back
        if (state is AdminUsersActionSuccess) {
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
        if (state is AdminUsersError) {
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

        final isLoading = state is AdminUsersLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Tambah User')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _teleponController,
                    decoration: const InputDecoration(labelText: 'Telepon'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Role'),
                    initialValue: _selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'plp', child: Text('PLP')),
                      DropdownMenuItem(value: 'user', child: Text('User')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Role harus dipilih';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
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