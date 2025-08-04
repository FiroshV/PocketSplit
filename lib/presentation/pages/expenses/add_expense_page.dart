import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/repositories/group_repository.dart';

class AddExpensePage extends StatefulWidget {
  final Group group;

  const AddExpensePage({super.key, required this.group});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Food & Dining';
  DateTime _selectedDate = DateTime.now();
  SplitMethod _selectedSplitMethod = SplitMethod.equal;

  List<Map<String, dynamic>> _members = [];
  List<String> _selectedPayers = [];
  Map<String, double> _memberAmounts = {};
  Map<String, double> _memberPercentages = {};
  Map<String, int> _memberShares = {};

  bool _isLoading = false;

  final List<String> _categories = [
    'Food & Dining',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Bills & Utilities',
    'Housing',
    'Healthcare',
    'Education',
    'Travel',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);

    try {
      final membersData = <Map<String, dynamic>>[];

      for (final memberId in widget.group.memberIds) {
        // In a real app, you'd have a user repository to get user details
        // For now, we'll create mock data based on current user
        final currentUser = getIt<AuthService>().currentUser!;

        if (memberId == currentUser.uid) {
          membersData.add({
            'id': memberId,
            'name': currentUser.displayName ?? 'You',
            'email': currentUser.email ?? '',
            'photoUrl': currentUser.photoURL,
          });
        } else {
          // For demo purposes, create mock users
          membersData.add({
            'id': memberId,
            'name': 'Member ${memberId.substring(0, 6)}',
            'email': 'member@example.com',
            'photoUrl': null,
          });
        }
      }

      setState(() {
        _members = membersData;
        _selectedPayers = [membersData.first['id']]; // Default to first member

        // Initialize equal amounts for all members
        final equalAmount = 0.0;
        for (final member in _members) {
          _memberAmounts[member['id']] = equalAmount;
          _memberPercentages[member['id']] = 100.0 / _members.length;
          _memberShares[member['id']] = 1;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading members: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateSplitAmounts() {
    if (_amountController.text.isEmpty) return;

    final totalAmount = double.tryParse(_amountController.text) ?? 0.0;

    setState(() {
      switch (_selectedSplitMethod) {
        case SplitMethod.equal:
          final equalAmount = totalAmount / _members.length;
          for (final member in _members) {
            _memberAmounts[member['id']] = equalAmount;
          }
          break;
        case SplitMethod.percentage:
          for (final member in _members) {
            final percentage = _memberPercentages[member['id']] ?? 0.0;
            _memberAmounts[member['id']] = totalAmount * (percentage / 100.0);
          }
          break;
        case SplitMethod.shares:
          final totalShares = _memberShares.values.fold(
            0,
            (sum, shares) => sum + shares,
          );
          if (totalShares > 0) {
            for (final member in _members) {
              final shares = _memberShares[member['id']] ?? 0;
              _memberAmounts[member['id']] =
                  totalAmount * (shares / totalShares);
            }
          }
          break;
        case SplitMethod.exact:
        case SplitMethod.adjustment:
          // For exact and adjustment, amounts are set manually
          break;
      }
    });
  }

  void _validateAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select who paid for this expense'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    final totalSplitAmount = _memberAmounts.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    if ((totalSplitAmount - totalAmount).abs() > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Split amounts (${totalSplitAmount.toStringAsFixed(2)}) don\'t match total amount (${totalAmount.toStringAsFixed(2)})',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = getIt<AuthService>().currentUser!;
      final expenseRepo = getIt<ExpenseRepository>();

      final splits = _members.map((member) {
        final amount = _memberAmounts[member['id']] ?? 0.0;
        return ExpenseSplit(
          userId: member['id'],
          amount: amount,
          percentage: _selectedSplitMethod == SplitMethod.percentage
              ? _memberPercentages[member['id']]
              : null,
          shares: _selectedSplitMethod == SplitMethod.shares
              ? _memberShares[member['id']]
              : null,
          isPayer: _selectedPayers.contains(member['id']),
        );
      }).toList();

      final expense = Expense(
        id: '',
        groupId: widget.group.id,
        description: _descriptionController.text,
        amount: totalAmount,
        currency: widget.group.currency,
        category: _selectedCategory,
        createdAt: DateTime.now(),
        date: _selectedDate,
        createdBy: currentUser.uid,
        paidBy: _selectedPayers,
        splits: splits,
        splitMethod: _selectedSplitMethod,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await expenseRepo.createExpense(expense);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully!'),
            backgroundColor: AppTheme.primary2,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: AppTheme.primary2,
        foregroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _validateAndSubmit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading && _members.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildPayersSection(),
                    const SizedBox(height: 24),
                    _buildSplitMethodSection(),
                    const SizedBox(height: 24),
                    _buildSplitDetailsSection(),
                    const SizedBox(height: 24),
                    _buildNotesSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'What was this expense for?',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount *',
                hintText: '0.00',
                prefixText: '${widget.group.currency} ',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
              onChanged: (_) => _updateSplitAmounts(),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showCategoryPicker,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.neutralGray),
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.lightGray,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(_selectedCategory),
                      color: _getCategoryColor(_selectedCategory),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: TextStyle(
                              color: AppTheme.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedCategory,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.neutralGray,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat.yMd().format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who Paid?',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select one or more people who paid for this expense',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ..._members.map((member) {
              final isSelected = _selectedPayers.contains(member['id']);
              return CheckboxListTile(
                title: Text(member['name']),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedPayers.add(member['id']);
                    } else {
                      _selectedPayers.remove(member['id']);
                    }
                  });
                },
                secondary: CircleAvatar(
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
                          ),
                        )
                      : null,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitMethodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Split?',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSplitMethodChip(
                    'Equally',
                    SplitMethod.equal,
                    Icons.pie_chart,
                  ),
                  const SizedBox(width: 8),
                  _buildSplitMethodChip(
                    'Exact Amounts',
                    SplitMethod.exact,
                    Icons.attach_money,
                  ),
                  const SizedBox(width: 8),
                  _buildSplitMethodChip(
                    'Percentages',
                    SplitMethod.percentage,
                    Icons.percent,
                  ),
                  const SizedBox(width: 8),
                  _buildSplitMethodChip(
                    'Shares',
                    SplitMethod.shares,
                    Icons.share,
                  ),
                  const SizedBox(width: 8),
                  _buildSplitMethodChip(
                    'Adjustment',
                    SplitMethod.adjustment,
                    Icons.tune,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitMethodChip(
    String label,
    SplitMethod method,
    IconData icon,
  ) {
    final isSelected = _selectedSplitMethod == method;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSplitMethod = method;
          _updateSplitAmounts();
        });
      },
      selectedColor: AppTheme.primary2,
      checkmarkColor: Colors.black,
    );
  }

  Widget _buildSplitDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Split Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: ${widget.group.currency} ${_memberAmounts.values.fold(0.0, (sum, amount) => sum + amount).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._members.map((member) => _buildMemberSplitTile(member)),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberSplitTile(Map<String, dynamic> member) {
    final memberId = member['id'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
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
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member['name'],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(width: 120, child: _buildSplitInput(memberId)),
        ],
      ),
    );
  }

  Widget _buildSplitInput(String memberId) {
    switch (_selectedSplitMethod) {
      case SplitMethod.equal:
        return Text(
          '${widget.group.currency} ${(_memberAmounts[memberId] ?? 0.0).toStringAsFixed(2)}',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold),
        );

      case SplitMethod.exact:
      case SplitMethod.adjustment:
        return TextFormField(
          initialValue: (_memberAmounts[memberId] ?? 0.0).toStringAsFixed(2),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            prefixText: '${widget.group.currency} ',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
          ),
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0.0;
            setState(() {
              _memberAmounts[memberId] = amount;
            });
          },
        );

      case SplitMethod.percentage:
        return TextFormField(
          initialValue: (_memberPercentages[memberId] ?? 0.0).toStringAsFixed(
            1,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            suffixText: '%',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          onChanged: (value) {
            final percentage = double.tryParse(value) ?? 0.0;
            setState(() {
              _memberPercentages[memberId] = percentage;
              _updateSplitAmounts();
            });
          },
        );

      case SplitMethod.shares:
        return TextFormField(
          initialValue: (_memberShares[memberId] ?? 1).toString(),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            suffixText: 'shares',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          onChanged: (value) {
            final shares = int.tryParse(value) ?? 1;
            setState(() {
              _memberShares[memberId] = shares;
              _updateSplitAmounts();
            });
          },
        );
    }
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add any additional notes about this expense...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary2
                            : AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary2
                              : AppTheme.neutralGray,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            color: _getCategoryColor(category),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
      case 'Other':
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
      case 'Other':
      default:
        return Icons.category;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
