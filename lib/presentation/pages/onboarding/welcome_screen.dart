import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../auth/sign_in_screen.dart';
import 'onboarding_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
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

  void _navigateToSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  void _navigateToOnboarding() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const OnboardingPage()),
    );
  }

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo/Icon
                        Container(
                          width: 150,
                          height: 150,
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
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 80,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // App Name
                        Text(
                          'PocketSplit',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppTheme.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 42,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tagline
                        Text(
                          'Simplify Sharing, Instantly Split',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.neutralGray,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Welcome message
                          Text(
                            'Welcome to the easiest way to split expenses with friends and track group spending!',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // Get Started Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _navigateToSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondary2,
                                foregroundColor: AppTheme.white,
                                elevation: 8,
                                shadowColor: AppTheme.secondary2.withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),

                          // Learn More Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: _navigateToOnboarding,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.secondary2,
                                side: BorderSide(
                                  color: AppTheme.secondary2,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Learn More',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Terms and Privacy
                          Text.rich(
                            TextSpan(
                              text: 'By continuing, you agree to our ',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.neutralGray,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: AppTheme.secondary1,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: AppTheme.secondary1,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
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
    );
  }
}