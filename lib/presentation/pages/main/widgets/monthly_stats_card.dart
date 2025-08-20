import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class MonthlyStatsCard extends StatelessWidget {
  final double monthlySpending;
  final int expenseCount;
  final String currency;
  final String mostActiveGroup;
  final VoidCallback? onTap;

  const MonthlyStatsCard({
    super.key,
    required this.monthlySpending,
    required this.expenseCount,
    required this.currency,
    required this.mostActiveGroup,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateFormat.MMMM().format(DateTime.now());

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightGray,
            width: 1,
          ),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_month,
                  color: AppTheme.oceanDark1,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$currentMonth Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Total Spent',
                  value: '$currency ${monthlySpending.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: AppTheme.oceanDark2,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatItem(
                  label: 'Expenses',
                  value: expenseCount.toString(),
                  icon: Icons.receipt,
                  color: AppTheme.oceanDark2,
                ),
              ),
            ],
          ),

          if (mostActiveGroup.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.oceanLight2.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.oceanDark2.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppTheme.oceanDark1,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Most Active Group',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.neutralGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mostActiveGroup,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.neutralGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}