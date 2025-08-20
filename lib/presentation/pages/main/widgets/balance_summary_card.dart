import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class BalanceSummaryCard extends StatelessWidget {
  final double totalBalance;
  final String currency;
  final VoidCallback? onTap;

  const BalanceSummaryCard({
    super.key,
    required this.totalBalance,
    required this.currency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = totalBalance >= 0;
    final isZero = totalBalance == 0;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isZero 
              ? [AppTheme.purpleLight1, AppTheme.purpleLight2]
              : isPositive 
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
            'Your Balance',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isZero ? AppTheme.black : AppTheme.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          if (isZero)
            Text(
              'All settled up!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.black,
                fontWeight: FontWeight.bold,
              ),
            )
          else ...[
            Text(
              isPositive ? 'You are owed' : 'You owe',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            
            Row(
              children: [
                Text(
                  '$currency ${totalBalance.abs().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: AppTheme.white,
                  size: 28,
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isZero 
                ? AppTheme.black.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: isZero ? AppTheme.black : AppTheme.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isZero 
                    ? 'No pending balances'
                    : 'Across all groups',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isZero ? AppTheme.black : AppTheme.white,
                    fontWeight: FontWeight.w500,
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