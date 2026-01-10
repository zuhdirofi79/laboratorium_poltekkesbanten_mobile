import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_state_provider.dart';
import 'features/auth/domain/auth_state.dart';
import 'features/auth/data/auth_models.dart';
import 'features/equipment/presentation/equipment_provider.dart';
import 'features/schedule/presentation/schedule_provider.dart';
import 'features/plp_approval/presentation/plp_approval_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/plp/plp_home_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/errors/security_blocked_screen.dart';
import 'screens/errors/rate_limit_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthStateProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => EquipmentProvider.create(),
        ),
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider.create(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlpApprovalProvider.create(),
        ),
      ],
      child: MaterialApp(
        title: 'Laboratorium Poltekkes Banten',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/admin': (context) => const AdminHomeScreen(),
          '/plp': (context) => const PLPHomeScreen(),
          '/user': (context) => const UserHomeScreen(),
        },
      ),
    );
  }

}

/// Auth Wrapper
/// 
/// Routes based on AuthState:
/// - Unauthenticated → LoginScreen
/// - Authenticated → Role-based Home
/// - Blocked → SecurityBlockedScreen
/// - RateLimited → RateLimitScreen
/// - Loading → Loading indicator
/// - Error → LoginScreen with error message
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateProvider>(
      builder: (context, authProvider, child) {
        final state = authProvider.authState;

        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is Unauthenticated) {
          return const LoginScreen();
        }

        if (state is Authenticated) {
          // Route based on role
          final user = state.user;
          switch (user.role) {
            case UserRole.admin:
              return const AdminHomeScreen();
            case UserRole.plp:
              return const PLPHomeScreen();
            case UserRole.user:
              return const UserHomeScreen();
          }
        }

        if (state is Blocked) {
          return SecurityBlockedScreen(blockedState: state);
        }

        if (state is RateLimited) {
          return RateLimitScreen(rateLimitedState: state);
        }

        if (state is AuthError) {
          // On error, show login screen
          // Error will be displayed via LoginScreen if needed
          return const LoginScreen();
        }

        // Fallback to login
        return const LoginScreen();
      },
    );
  }
}