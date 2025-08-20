import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocket_split/core/theme/app_theme.dart';
import 'package:pocket_split/presentation/bloc/auth/auth_bloc.dart';
import 'package:pocket_split/presentation/bloc/auth/auth_event.dart';
import 'package:pocket_split/presentation/bloc/auth/auth_state.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(AuthSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign-in failed: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Logo/Icon
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
                          const SizedBox(height: 32),
                          
                          // App Name
                          Text(
                            'PocketSplit',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                              color: AppTheme.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Tagline
                          Text(
                            'Simplify Sharing, Instantly Split',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Expanded(
                    flex: 1,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // Welcome message
                            Text(
                              'Welcome to the easiest way to split expenses with friends!',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            
                            // Google Sign-In Button
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    onPressed: isLoading ? null : _signInWithGoogle,
                                    icon: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppTheme.white,
                                            ),
                                          )
                                        : Image.asset(
                                            'assets/images/google_logo.png',
                                            width: 24,
                                            height: 24,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.login,
                                                color: AppTheme.white,
                                              );
                                            },
                                          ),
                                    label: Text(
                                      isLoading ? 'Signing in...' : 'Continue with Google',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.secondary2,
                                      foregroundColor: AppTheme.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      shadowColor: AppTheme.primary2.withValues(alpha: 0.3),
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Terms and Privacy
                            Text.rich(
                              TextSpan(
                                text: 'By continuing, you agree to our ',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.secondary1,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.secondary1,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
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