import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class MonthlyAnalyticsScreen extends StatelessWidget {
  final double monthlySpending;
  final int expenseCount;
  final String currency;
  final String mostActiveGroup;

  const MonthlyAnalyticsScreen({
    super.key,
    required this.monthlySpending,
    required this.expenseCount,
    required this.currency,
    required this.mostActiveGroup,
  });

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateFormat.MMMM().format(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$currentMonth Analytics',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.black),
      ),
      backgroundColor: AppTheme.lightGray,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.oceanLight1, AppTheme.oceanDark1],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 0,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$currentMonth Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Spent',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$currency ${monthlySpending.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              expenseCount.toString(),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Expenses',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  if (mostActiveGroup.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppTheme.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Most Active Group',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.white.withValues(alpha: 0.8),
                                ),
                              ),
                              Text(
                                mostActiveGroup,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Detailed Breakdown',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Coming Soon Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.lightGray),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 0,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.analytics,
                    size: 48,
                    color: AppTheme.oceanDark1,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Advanced Analytics Coming Soon!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category breakdown, spending trends,\ncharts, and detailed expense history\nwill be available in upcoming updates.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutralGray,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Feature Preview Cards
            Row(
              children: [
                Expanded(
                  child: _FeaturePreviewCard(
                    icon: Icons.pie_chart,
                    title: 'Category\nBreakdown',
                    color: AppTheme.primary1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeaturePreviewCard(
                    icon: Icons.trending_up,
                    title: 'Spending\nTrends',
                    color: AppTheme.secondary1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeaturePreviewCard(
                    icon: Icons.list_alt,
                    title: 'Expense\nHistory',
                    color: AppTheme.oceanDark1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePreviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _FeaturePreviewCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}