import 'package:flutter/material.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../core/errors/error_code.dart';
import '../../utils/app_theme.dart';

/// Security Blocked Screen
/// 
/// Displayed when user/IP is blocked by reputation system
/// Shows block_until timestamp if available
class SecurityBlockedScreen extends StatelessWidget {
  final Blocked blockedState;

  const SecurityBlockedScreen({
    super.key,
    required this.blockedState,
  });

  @override
  Widget build(BuildContext context) {
    final failure = blockedState.failure;
    final blockUntil = blockedState.blockUntil;
    final isPermanent = blockedState.isPermanent;
    final isBlocked = blockedState.isBlocked;

    String message;
    String? expirationInfo;

    if (isPermanent) {
      message = 'Akses Anda telah diblokir secara permanen.';
      expirationInfo = 'Silakan hubungi administrator untuk bantuan.';
    } else if (blockUntil != null) {
      if (isBlocked) {
        final now = DateTime.now();
        final remaining = blockUntil.difference(now);
        final hours = remaining.inHours;
        final minutes = remaining.inMinutes.remainder(60);
        
        message = 'Akses Anda diblokir sementara.';
        expirationInfo = 'Blokir akan berakhir dalam ${hours}j ${minutes}m';
      } else {
        message = 'Blokir telah berakhir.';
        expirationInfo = 'Silakan coba lagi.';
      }
    } else {
      message = 'Akses Anda telah diblokir.';
      expirationInfo = 'Silakan hubungi administrator.';
    }

    // Determine error code message
    String errorDetail = '';
    switch (failure.errorCode) {
      case ErrorCode.reputationBlocked:
        errorDetail = 'Blokir karena aktivitas mencurigakan.';
        break;
      case ErrorCode.ipBlocked:
        errorDetail = 'Blokir berdasarkan alamat IP.';
        break;
      case ErrorCode.forbiddenRole:
        errorDetail = 'Akses ditolak karena peran tidak diizinkan.';
        break;
      default:
        errorDetail = failure.message;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.errorColor,
              AppTheme.errorColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.block,
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Akses Diblokir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (errorDetail.isNotEmpty)
                    Text(
                      errorDetail,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      expirationInfo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (blockUntil != null && !isBlocked)
                    ElevatedButton(
                      onPressed: () {
                        // Navigate back to login when block expires
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.errorColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
