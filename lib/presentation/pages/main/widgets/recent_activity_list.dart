import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/expense.dart';

class RecentActivityList extends StatelessWidget {
  final List<Expense> recentExpenses;
  final Function(String) onExpenseTap;

  const RecentActivityList({
    super.key,
    required this.recentExpenses,
    required this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recentExpenses.isEmpty) {
      return _EmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full activity page
              },
              child: Text(
                'See all',
                style: TextStyle(
                  color: AppTheme.secondary2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        ...recentExpenses.take(5).map((expense) => _ActivityItem(
          expense: expense,
          onTap: () => onExpenseTap(expense.id),
        )),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const _ActivityItem({
    required this.expense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate user's share
    final userShare = expense.splits.isNotEmpty 
      ? expense.splits.first.amount 
      : expense.amount / expense.splits.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightGray,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neutralGray.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getCategoryColor(expense.category).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimeAgo(expense.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neutralGray,
                    ),
                  ),
                ],
              ),
            ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${expense.currency} ${expense.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your share: ${expense.currency} ${userShare.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Dining':
        return Colors.orange;
      case 'Transportation':
        return Colors.blue;
      case 'Entertainment':
        return Colors.purple;
      case 'Shopping':
        return Colors.pink;
      case 'Bills & Utilities':
        return Colors.red;
      case 'Housing':
        return Colors.brown;
      case 'Healthcare':
        return Colors.green;
      case 'Education':
        return Colors.indigo;
      case 'Travel':
        return Colors.teal;
      default:
        return AppTheme.neutralGray;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant;
      case 'Transportation':
        return Icons.directions_car;
      case 'Entertainment':
        return Icons.movie;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills & Utilities':
        return Icons.receipt;
      case 'Housing':
        return Icons.home;
      case 'Healthcare':
        return Icons.medical_services;
      case 'Education':
        return Icons.school;
      case 'Travel':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat.MMMd().format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 64,
            color: AppTheme.neutralGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No recent activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.neutralGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first expense to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.neutralGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}