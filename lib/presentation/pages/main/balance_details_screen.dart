import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BalanceDetailsScreen extends StatelessWidget {
  final double totalBalance;
  final String currency;

  const BalanceDetailsScreen({
    super.key,
    required this.totalBalance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Balance Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.black),
      ),
      backgroundColor: AppTheme.lightGray,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Balance Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: totalBalance >= 0
                      ? [AppTheme.primary1, AppTheme.primary2]
                      : [AppTheme.black, AppTheme.purpleDark2],
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
                    'Total Balance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '$currency ${totalBalance.abs().toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        totalBalance >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: AppTheme.black,
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    totalBalance >= 0 ? 'You are owed' : 'You owe',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Group Breakdown',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Coming Soon Card
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
                    Icons.construction,
                    size: 48,
                    color: AppTheme.primary2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Coming Soon!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Detailed balance breakdown by groups,\nindividual debts, and settlement options\nwill be available in the next update.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutralGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}