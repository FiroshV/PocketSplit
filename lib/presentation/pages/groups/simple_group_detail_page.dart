import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_split/core/theme/app_theme.dart';
import 'package:pocket_split/core/services/auth_service.dart';
import 'package:pocket_split/core/di/service_locator.dart';
import 'package:pocket_split/domain/entities/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SimpleGroupDetailPage extends StatefulWidget {
  final Group group;

  const SimpleGroupDetailPage({
    super.key,
    required this.group,
  });

  @override
  State<SimpleGroupDetailPage> createState() => _SimpleGroupDetailPageState();
}

class _SimpleGroupDetailPageState extends State<SimpleGroupDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Sample data - in a real implementation, this would come from the database
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _members = [];
  Map<String, double> _balances = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    try {
      // Load members
      final membersData = <Map<String, dynamic>>[];
      for (final memberId in widget.group.memberIds) {
        final userDoc = await _firestore.collection('users').doc(memberId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          membersData.add({
            'id': memberId,
            'name': userData['displayName'] ?? 'Unknown',
            'email': userData['email'] ?? '',
            'photoUrl': userData['photoUrl'],
            'isAdmin': memberId == widget.group.createdBy,
          });
        }
      }

      // Sample expenses for demonstration
      final sampleExpenses = <Map<String, dynamic>>[
        {
          'id': '1',
          'description': 'Dinner at Restaurant',
          'amount': 120.50,
          'currency': widget.group.currency,
          'category': 'Food & Dining',
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'paidBy': membersData.isNotEmpty ? membersData[0]['name'] : 'Someone',
          'paidById': membersData.isNotEmpty ? membersData[0]['id'] : '',
          'splits': membersData.map((member) => {
            'userId': member['id'],
            'userName': member['name'],
            'amount': 120.50 / membersData.length,
          }).toList(),
        },
        {
          'id': '2',
          'description': 'Uber Ride',
          'amount': 25.00,
          'currency': widget.group.currency,
          'category': 'Transportation',
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'paidBy': membersData.length > 1 ? membersData[1]['name'] : 'Someone',
          'paidById': membersData.length > 1 ? membersData[1]['id'] : '',
          'splits': membersData.map((member) => {
            'userId': member['id'],
            'userName': member['name'],
            'amount': 25.00 / membersData.length,
          }).toList(),
        },
      ];

      // Calculate balances
      final balances = <String, double>{};
      final currentUser = getIt<AuthService>().currentUser;
      
      for (final member in membersData) {
        balances[member['id']] = 0.0;
      }

      for (final expense in sampleExpenses) {
        final splits = expense['splits'] as List;
        final paidById = expense['paidById'] as String;
        final totalAmount = expense['amount'] as double;
        
        // Add amount to payer's balance
        balances[paidById] = (balances[paidById] ?? 0.0) + totalAmount;
        
        // Subtract split amounts from each participant
        for (final split in splits) {
          final userId = split['userId'] as String;
          final amount = split['amount'] as double;
          balances[userId] = (balances[userId] ?? 0.0) - amount;
        }
      }

      setState(() {
        _members = membersData;
        _expenses = sampleExpenses;
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: AppTheme.primary2,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpensesTab() {
    if (_expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first expense to start tracking costs',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddExpenseDialog,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Add Expense',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary2),
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

  Widget _buildExpenseCard(Map<String, dynamic> expense) {
    final currentUser = getIt<AuthService>().currentUser!;
    final userSplit = (expense['splits'] as List).firstWhere(
      (split) => split['userId'] == currentUser.uid,
      orElse: () => {'userId': '', 'userName': '', 'amount': 0.0},
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(expense['category']),
          child: Icon(
            _getCategoryIcon(expense['category']),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          expense['description'],
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Paid by ${expense['paidBy']}'),
            Text(
              '${_formatDate(expense['date'])} • ${expense['category']}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${expense['currency']} ${expense['amount'].toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            if (userSplit['userId'] != '') ...[
              Text(
                expense['paidById'] == currentUser.uid
                    ? 'You paid ${expense['currency']} ${userSplit['amount'].toStringAsFixed(2)}'
                    : 'You owe ${expense['currency']} ${userSplit['amount'].toStringAsFixed(2)}',
                style: TextStyle(
                  color: expense['paidById'] == currentUser.uid ? Colors.green : Colors.red,
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
                            backgroundColor: balance >= 0 ? Colors.green : Colors.red,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: member['isAdmin'] ? AppTheme.primary2 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    member['isAdmin'] ? 'Admin' : 'Member',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: member['isAdmin'] ? Colors.black : Colors.grey.shade700,
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
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Text(
              'The member will be notified and can join the group',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement actual member addition
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invite sent to ${emailController.text}'),
                  backgroundColor: AppTheme.primary2,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary2,
              foregroundColor: Colors.black,
            ),
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  void _shareInviteLink() {
    final inviteCode = _generateInviteCode();
    final inviteText = 'Join my PocketSplit group "${widget.group.name}" using code: $inviteCode';
    
    Clipboard.setData(ClipboardData(text: inviteText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite link copied to clipboard!'),
        backgroundColor: AppTheme.primary2,
      ),
    );
  }

  void _showAddExpenseDialog() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Food & Dining';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What was this for?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                    prefixText: '${widget.group.currency} ',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Food & Dining',
                    'Transportation',
                    'Entertainment',
                    'Shopping',
                    'Bills & Utilities',
                    'Other',
                  ].map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descriptionController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  // TODO: Implement actual expense addition
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense added successfully!'),
                      backgroundColor: AppTheme.primary2,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary2,
                foregroundColor: Colors.black,
              ),
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}