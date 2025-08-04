import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pocket_split/core/theme/app_theme.dart';
import 'package:pocket_split/core/services/auth_service.dart';
import 'package:pocket_split/core/di/service_locator.dart';
import 'package:pocket_split/domain/entities/group.dart';
import 'package:pocket_split/domain/entities/expense.dart';
import 'package:pocket_split/domain/repositories/group_repository.dart';
import 'package:pocket_split/domain/repositories/expense_repository.dart';
import 'package:pocket_split/presentation/pages/expenses/add_expense_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SimpleGroupDetailPage extends StatefulWidget {
  final Group group;

  const SimpleGroupDetailPage({super.key, required this.group});

  @override
  State<SimpleGroupDetailPage> createState() => _SimpleGroupDetailPageState();
}

class _SimpleGroupDetailPageState extends State<SimpleGroupDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Expense> _expenses = [];
  List<Map<String, dynamic>> _members = [];
  Map<String, double> _balances = {};
  bool _isLoading = true;

  late ExpenseRepository _expenseRepository;
  late GroupRepository _groupRepository;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _expenseRepository = getIt<ExpenseRepository>();
    _groupRepository = getIt<GroupRepository>();
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    try {
      // Load members
      final membersData = <Map<String, dynamic>>[];
      for (final memberId in widget.group.memberIds) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          membersData.add({
            'id': memberId,
            'name': userData['displayName'] ?? 'Unknown',
            'email': userData['email'] ?? '',
            'photoUrl': userData['photoUrl'],
            'isAdmin': memberId == widget.group.createdBy,
          });
        } else {
          // Fallback for users not found in Firestore
          final currentUser = getIt<AuthService>().currentUser;
          if (memberId == currentUser?.uid) {
            membersData.add({
              'id': memberId,
              'name': currentUser?.displayName ?? 'You',
              'email': currentUser?.email ?? '',
              'photoUrl': currentUser?.photoURL,
              'isAdmin': memberId == widget.group.createdBy,
            });
          } else {
            membersData.add({
              'id': memberId,
              'name': 'Member ${memberId.substring(0, 6)}',
              'email': 'unknown@example.com',
              'photoUrl': null,
              'isAdmin': memberId == widget.group.createdBy,
            });
          }
        }
      }

      // Load real expenses
      final expenses = await _expenseRepository.getGroupExpenses(
        widget.group.id,
      );

      // Calculate balances
      final balances = <String, double>{};

      for (final member in membersData) {
        balances[member['id']] = 0.0;
      }

      for (final expense in expenses) {
        // Add amount to payers' balances
        final totalPaid = expense.amount / expense.paidBy.length;
        for (final payerId in expense.paidBy) {
          balances[payerId] = (balances[payerId] ?? 0.0) + totalPaid;
        }

        // Subtract split amounts from each participant
        for (final split in expense.splits) {
          balances[split.userId] =
              (balances[split.userId] ?? 0.0) - split.amount;
        }
      }

      setState(() {
        _members = membersData;
        _expenses = expenses;
        _balances = balances;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading group data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        backgroundColor: AppTheme.primary2,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Expenses', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Balances', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Members', icon: Icon(Icons.group)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'add_member':
                  _showAddMemberDialog();
                  break;
                case 'share_invite':
                  _shareInviteLink();
                  break;
                case 'add_expense':
                  _showAddExpenseDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_expense',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Add Expense'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_member',
                child: Row(
                  children: [
                    Icon(Icons.person_add),
                    SizedBox(width: 8),
                    Text('Add Member'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share_invite',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share Invite'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildExpensesTab(),
                _buildBalancesTab(),
                _buildMembersTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        backgroundColor: AppTheme.primary2,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildExpensesTab() {
    if (_expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first expense to start tracking costs',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return _buildExpenseCard(expense);
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    final currentUser = getIt<AuthService>().currentUser!;
    final userSplit = expense.splits.firstWhere(
      (split) => split.userId == currentUser.uid,
      orElse: () => const ExpenseSplit(userId: '', amount: 0.0),
    );

    final paidByNames = expense.paidBy
        .map((payerId) {
          if (payerId == currentUser.uid) return 'You';
          final member = _members.firstWhere(
            (m) => m['id'] == payerId,
            orElse: () => {'name': 'Unknown', 'id': payerId},
          );
          return member['name'];
        })
        .join(', ');

    final isPaidByCurrentUser = expense.paidBy.contains(currentUser.uid);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(expense.category),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Paid by $paidByNames'),
            Text(
              '${_formatDate(expense.date)} • ${expense.category}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${expense.currency} ${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            if (userSplit.userId.isNotEmpty) ...[
              Text(
                isPaidByCurrentUser
                    ? 'You paid ${expense.currency} ${userSplit.amount.toStringAsFixed(2)}'
                    : 'You owe ${expense.currency} ${userSplit.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isPaidByCurrentUser ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalancesTab() {
    final currentUser = getIt<AuthService>().currentUser!;
    final userBalance = _balances[currentUser.uid] ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Your Balance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userBalance >= 0
                        ? '+${widget.group.currency} ${userBalance.abs().toStringAsFixed(2)}'
                        : '-${widget.group.currency} ${userBalance.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: userBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userBalance >= 0 ? 'You are owed' : 'You owe',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Balances',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._members.map((member) {
                    final balance = _balances[member['id']] ?? 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: balance >= 0
                                ? Colors.green
                                : Colors.red,
                            backgroundImage: member['photoUrl'] != null
                                ? NetworkImage(member['photoUrl'])
                                : null,
                            child: member['photoUrl'] == null
                                ? Text(
                                    member['name'].isNotEmpty
                                        ? member['name'][0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  balance >= 0 ? 'is owed' : 'owes',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${widget.group.currency} ${balance.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: balance >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _members.length + 1, // +1 for add member card
      itemBuilder: (context, index) {
        if (index == _members.length) {
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary2,
                child: const Icon(Icons.person_add, color: Colors.black),
              ),
              title: const Text(
                'Add Member',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Invite someone to join this group'),
              onTap: _showAddMemberDialog,
            ),
          );
        }

        final member = _members[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.secondary1,
              backgroundImage: member['photoUrl'] != null
                  ? NetworkImage(member['photoUrl'])
                  : null,
              child: member['photoUrl'] == null
                  ? Text(
                      member['name'].isNotEmpty
                          ? member['name'][0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            title: Text(
              member['name'],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(member['email']),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: member['isAdmin']
                        ? AppTheme.primary2
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    member['isAdmin'] ? 'Admin' : 'Member',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: member['isAdmin']
                          ? Colors.black
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      default:
        return Colors.grey;
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
      default:
        return Icons.attach_money;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddMemberDialog() {
    final emailController = TextEditingController();
    final inviteCodeController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add by Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter member\'s email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Or Join with Code',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: inviteCodeController,
                decoration: const InputDecoration(
                  labelText: 'Invite Code',
                  hintText: 'Enter 8-character code',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 8,
              ),
              const SizedBox(height: 16),
              Text(
                'Members can join using either method',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (emailController.text.trim().isEmpty &&
                          inviteCodeController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter an email or invite code',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        if (inviteCodeController.text.trim().isNotEmpty) {
                          // Join group with invite code
                          final group = await _groupRepository
                              .getGroupByInviteCode(
                                inviteCodeController.text.trim().toUpperCase(),
                              );

                          if (group == null) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invalid invite code'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          final currentUser = getIt<AuthService>().currentUser!;
                          if (!group.memberIds.contains(currentUser.uid)) {
                            await _groupRepository.addMemberToGroup(
                              group.id,
                              currentUser.uid,
                            );
                          }

                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Successfully joined group!'),
                                backgroundColor: AppTheme.primary2,
                              ),
                            );
                          }
                        } else {
                          // For email-based invites, we would need to implement email sending
                          // For now, just show a placeholder message
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Invite sent to ${emailController.text} (Feature coming soon)',
                                ),
                                backgroundColor: AppTheme.primary2,
                              ),
                            );
                          }
                        }

                        // Reload group data
                        _loadGroupData();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary2,
                foregroundColor: Colors.black,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }

  void _shareInviteLink() async {
    try {
      // Generate invite code if it doesn't exist
      String inviteCode = widget.group.inviteCode ?? '';
      if (inviteCode.isEmpty) {
        inviteCode = await _groupRepository.generateInviteCode(widget.group.id);
      }

      final inviteText =
          'Join my PocketSplit group "${widget.group.name}" using code: $inviteCode\n\nDownload PocketSplit to get started!';

      // Use share_plus to share the invite
      await Share.share(
        inviteText,
        subject: 'Join my PocketSplit group: ${widget.group.name}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing invite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddExpenseDialog() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddExpensePage(group: widget.group),
      ),
    );

    // If expense was added successfully, reload the data
    if (result == true) {
      _loadGroupData();
    }
  }
}
