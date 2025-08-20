import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/repositories/group_repository.dart';
import '../groups/create_group_page.dart';
import 'widgets/balance_summary_card.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/monthly_stats_card.dart';
import 'balance_details_screen.dart';
import 'monthly_analytics_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = getIt<AuthService>();
  final ExpenseRepository _expenseRepository = getIt<ExpenseRepository>();
  final GroupRepository _groupRepository = getIt<GroupRepository>();

  bool _isLoading = true;
  double _totalBalance = 0.0;
  double _monthlySpending = 0.0;
  int _expenseCount = 0;
  String _mostActiveGroup = '';
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      // Get user's groups
      final userGroups = await _groupRepository.getUserGroups(userId);

      if (userGroups.isNotEmpty) {
        // Get expenses from all user's groups
        List<Expense> allExpenses = [];
        for (final group in userGroups) {
          final groupExpenses = await _expenseRepository.getGroupExpenses(
            group.id,
          );
          allExpenses.addAll(groupExpenses);
        }

        // Sort expenses by date (newest first)
        allExpenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Calculate total balance across all groups
        double totalBalance = 0.0;
        for (final expense in allExpenses) {
          for (final split in expense.splits) {
            if (split.userId == userId) {
              // User owes this amount
              totalBalance -= split.amount;
            }
          }
          // If user paid for the expense
          if (expense.paidBy.contains(userId)) {
            totalBalance += expense.amount;
          }
        }

        // Calculate monthly stats
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final monthlyExpenses = allExpenses
            .where((expense) => expense.createdAt.isAfter(monthStart))
            .toList();

        double calculatedMonthlySpending = 0.0;
        
        for (final expense in monthlyExpenses) {
          for (final split in expense.splits) {
            if (split.userId == userId) {
              calculatedMonthlySpending += split.amount;
            }
          }
        }

        // Find most active group
        String mostActiveGroup = '';
        if (userGroups.isNotEmpty) {
          Map<String, int> groupExpenseCounts = {};
          for (final expense in monthlyExpenses) {
            final groupName = userGroups
                .firstWhere(
                  (g) => g.id == expense.groupId,
                  orElse: () => userGroups.first,
                )
                .name;
            groupExpenseCounts[groupName] =
                (groupExpenseCounts[groupName] ?? 0) + 1;
          }

          if (groupExpenseCounts.isNotEmpty) {
            mostActiveGroup = groupExpenseCounts.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key;
          }
        }

        if (mounted) {
          setState(() {
            _totalBalance = totalBalance;
            _monthlySpending = calculatedMonthlySpending;
            _expenseCount = monthlyExpenses.length;
            _mostActiveGroup = mostActiveGroup;
            _currency = userGroups.isNotEmpty
                ? userGroups.first.currency
                : 'USD';
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddExpenseDialog() {
    // Show bottom sheet to select group first, then navigate to add expense
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a group to add expense',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to group selection or create group first
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create a group first to add expenses'),
                    backgroundColor: AppTheme.secondary2,
                  ),
                );
              },
              child: const Text('Create Group First'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateGroup() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CreateGroupPage()))
        .then((_) {
          // Refresh data when returning from create group
          _loadDashboardData();
        });
  }

  void _showSettleUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settlement System'),
        content: const Text('Settlement functionality will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToBalanceDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BalanceDetailsScreen(
          totalBalance: _totalBalance,
          currency: _currency,
        ),
      ),
    );
  }

  void _navigateToMonthlyAnalytics() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MonthlyAnalyticsScreen(
          monthlySpending: _monthlySpending,
          expenseCount: _expenseCount,
          currency: _currency,
          mostActiveGroup: _mostActiveGroup,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
        child: Column(
          children: [
            if (_isLoading) ...[
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primary2,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ] else ...[
              // Balance Summary Card
              BalanceSummaryCard(
                totalBalance: _totalBalance,
                currency: _currency,
                onTap: _navigateToBalanceDetails,
              ),
              const SizedBox(height: 24),

              // Quick Actions
              QuickActionsRow(
                onAddExpense: _showAddExpenseDialog,
                onCreateGroup: _navigateToCreateGroup,
                onSettleUp: _showSettleUpDialog,
              ),
              const SizedBox(height: 32),

              // Monthly Stats
              MonthlyStatsCard(
                monthlySpending: _monthlySpending,
                expenseCount: _expenseCount,
                currency: _currency,
                mostActiveGroup: _mostActiveGroup,
                onTap: _navigateToMonthlyAnalytics,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
