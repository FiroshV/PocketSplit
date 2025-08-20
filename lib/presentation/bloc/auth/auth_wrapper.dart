import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../pages/onboarding/welcome_screen.dart';
import '../../pages/main/main_app_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../user_settings/user_settings_bloc.dart';
import '../user_settings/user_settings_event.dart';
import 'auth_bloc.dart';
import 'auth_state.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Load user settings when user is authenticated
          context.read<UserSettingsBloc>().add(
            LoadUserSettingsEvent(state.user.uid),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const _LoadingScreen();
          } else if (state is AuthAuthenticated) {
            return const MainAppScreen();
          } else {
            // AuthUnauthenticated or AuthError
            return const WelcomeScreen();
          }
        },
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary1.withValues(alpha: 0.1),
              AppTheme.primary2.withValues(alpha: 0.05),
              AppTheme.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary1,
                      AppTheme.primary2,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary2.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 60,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 48),
              
              Text(
                'PocketSplit',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary2),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.neutralGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}