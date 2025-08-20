import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../auth/sign_in_screen.dart';
import 'widgets/feature_highlight_card.dart';
import 'widgets/page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.receipt_long,
      'title': 'Split Expenses Easily',
      'description': 'Add expenses and split them with friends instantly. Choose equal splits, exact amounts, or custom percentages.',
      'color': Colors.orange,
    },
    {
      'icon': Icons.groups,
      'title': 'Track Group Spending',
      'description': 'Create groups for trips, roommates, or regular outings. Keep track of who owes what in real-time.',
      'color': Colors.blue,
    },
    {
      'icon': Icons.payment,
      'title': 'Settle Up Instantly',
      'description': 'See who owes whom and settle debts with integrated payment options. Simplify complex group balances.',
      'color': Colors.green,
    },
    {
      'icon': Icons.people,
      'title': 'Manage Friends & Groups',
      'description': 'Invite friends, manage group members, and track spending across multiple groups with ease.',
      'color': Colors.purple,
    },
  ];

  void _nextPage() {
    if (_currentPage < _features.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToSignIn();
    }
  }

  void _skipToSignIn() {
    _navigateToSignIn();
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.white,
              AppTheme.primary1.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _skipToSignIn,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppTheme.neutralGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Feature Pages
              Expanded(
                flex: 4,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _features.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final feature = _features[index];
                    return FeatureHighlightCard(
                      icon: feature['icon'],
                      title: feature['title'],
                      description: feature['description'],
                      iconColor: feature['color'],
                    );
                  },
                ),
              ),

              // Page Indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: PageIndicator(
                  currentPage: _currentPage,
                  totalPages: _features.length,
                ),
              ),

              // Bottom Navigation
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    // Back Button (visible after first page)
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.neutralGray,
                            side: BorderSide(color: AppTheme.lightGray),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),

                    if (_currentPage > 0) const SizedBox(width: 16),

                    // Next/Get Started Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary2,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shadowColor: AppTheme.secondary2.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentPage == _features.length - 1 ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}