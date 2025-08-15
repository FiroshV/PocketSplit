import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

enum FriendsFilter { all, outstandingBalances, friendsYouOwe, friendsWhoOweYou }

class Expense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });
}

class Friend {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final List<Expense> expenses;
  final DateTime? addedAt;

  Friend({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.expenses = const [],
    this.addedAt,
  });

  double get totalBalance {
    return expenses.fold(0, (total, expense) => total + expense.amount);
  }

  bool get hasOutstandingBalance => totalBalance != 0;
  bool get owesYou => totalBalance > 0;
  bool get youOwe => totalBalance < 0;

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'addedAt': addedAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory Friend.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Friend(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      profileImage: data['profileImage'],
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Friend> _friends = [];
  List<Friend> _filteredFriends = [];
  FriendsFilter _selectedFilter = FriendsFilter.all;
  final Set<String> _expandedFriends = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _friends = [];
          _isLoading = false;
        });
        _applyFilters();
        return;
      }

      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .orderBy('addedAt', descending: true)
          .get();

      final friends = friendsSnapshot.docs
          .map((doc) => Friend.fromFirestore(doc))
          .toList();

      // Add mock expenses for demonstration (in real app, load from expenses collection)
      final friendsWithExpenses = friends.map((friend) {
        // Mock expenses for demo - replace with real expense loading logic
        List<Expense> mockExpenses = [];
        if (friend.name.toLowerCase().contains('john')) {
          mockExpenses = [
            Expense(
              id: '1',
              description: 'Trip to Paris',
              amount: 150.0,
              date: DateTime.now(),
            ),
            Expense(
              id: '2',
              description: 'Dinner at restaurant',
              amount: 45.0,
              date: DateTime.now(),
            ),
          ];
        } else if (friend.name.toLowerCase().contains('jane')) {
          mockExpenses = [
            Expense(
              id: '3',
              description: 'Concert tickets',
              amount: -80.0,
              date: DateTime.now(),
            ),
          ];
        }

        return Friend(
          id: friend.id,
          name: friend.name,
          email: friend.email,
          phoneNumber: friend.phoneNumber,
          profileImage: friend.profileImage,
          addedAt: friend.addedAt,
          expenses: mockExpenses,
        );
      }).toList();

      setState(() {
        _friends = friendsWithExpenses;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      developer.log('Error loading friends: $e', name: 'FriendsPage', error: e);
      setState(() {
        _friends = [];
        _isLoading = false;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends = _friends.where((friend) {
        // First apply search filter
        final matchesSearch =
            query.isEmpty ||
            friend.name.toLowerCase().contains(query) ||
            friend.email.toLowerCase().contains(query) ||
            (friend.phoneNumber?.contains(query) ?? false);

        if (!matchesSearch) return false;

        // Then apply balance filter
        switch (_selectedFilter) {
          case FriendsFilter.all:
            return true;
          case FriendsFilter.outstandingBalances:
            return friend.hasOutstandingBalance;
          case FriendsFilter.friendsYouOwe:
            return friend.youOwe;
          case FriendsFilter.friendsWhoOweYou:
            return friend.owesYou;
        }
      }).toList();
    });
  }

  double get _totalOwedToYou {
    return _friends.fold(
      0,
      (total, friend) => total + (friend.owesYou ? friend.totalBalance : 0),
    );
  }

  String get _filterDescription {
    switch (_selectedFilter) {
      case FriendsFilter.all:
        return 'Showing all friends';
      case FriendsFilter.outstandingBalances:
        return 'Showing friends with outstanding balances';
      case FriendsFilter.friendsYouOwe:
        return 'Showing friends you owe';
      case FriendsFilter.friendsWhoOweYou:
        return 'Showing friends who owe you';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar with add friend button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search friends...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _navigateToAddFriends(),
                  icon: const Icon(Icons.person_add),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),

          // Overall balance
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _totalOwedToYou >= 0
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _totalOwedToYou >= 0
                    ? Colors.green.shade200
                    : Colors.red.shade200,
              ),
            ),
            child: Text(
              'Overall, you are owed \$${_totalOwedToYou.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _totalOwedToYou >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ),

          // Filter dropdown and description
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                PopupMenuButton<FriendsFilter>(
                  onSelected: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    _applyFilters();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: FriendsFilter.all,
                      child: Row(
                        children: [
                          Icon(Icons.people),
                          SizedBox(width: 8),
                          Text('All friends'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: FriendsFilter.outstandingBalances,
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet),
                          SizedBox(width: 8),
                          Text('Outstanding balances'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: FriendsFilter.friendsYouOwe,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Friends you owe'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: FriendsFilter.friendsWhoOweYou,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Friends who owe you'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list),
                        SizedBox(width: 4),
                        Text('Filter'),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _filterDescription,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // Friends list
          Expanded(
            child: _filteredFriends.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredFriends.length,
                    itemBuilder: (context, index) {
                      final friend = _filteredFriends[index];
                      return _buildFriendTile(friend);
                    },
                  ),
          ),

          // Add more friends button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () => _navigateToAddFriends(),
              icon: const Icon(Icons.person_add),
              label: const Text('Add more friends'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendTile(Friend friend) {
    final isExpanded = _expandedFriends.contains(friend.id);
    final hasMultipleExpenses = friend.expenses.length > 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              friend.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: friend.hasOutstandingBalance
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.owesYou ? 'owes you' : 'you owe',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$${friend.totalBalance.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: friend.owesYou ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'settled up',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
            trailing: hasMultipleExpenses && friend.hasOutstandingBalance
                ? IconButton(
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedFriends.remove(friend.id);
                        } else {
                          _expandedFriends.add(friend.id);
                        }
                      });
                    },
                  )
                : null,
          ),
          if (isExpanded && friend.expenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 72, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: friend.expenses.map((expense) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '├── ',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${friend.name} ${expense.amount > 0 ? 'owes you' : 'you owe'} \$${expense.amount.abs().toStringAsFixed(2)} for "${expense.description}"',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'No friends found'
                : 'No friends yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try a different search term'
                : 'Add friends to start splitting expenses',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _navigateToAddFriends() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFriendsPage()),
    );
    // Reload friends when returning from add friends page
    _loadFriends();
  }
}

class AddFriendsPage extends StatefulWidget {
  const AddFriendsPage({super.key});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<PhoneContact> _contacts = [];
  List<PhoneContact> _filteredContacts = [];
  final Set<String> _selectedContactIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterContacts);
    // Start loading contacts immediately
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    developer.log('Starting contact loading...', name: 'FriendsPage');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try to load contacts directly first - flutter_contacts handles permissions internally
      developer.log('Attempting to load contacts directly...', name: 'FriendsPage');

      final List<Contact> testContacts = await FlutterContacts.getContacts();
      developer.log('Direct contact loading result: ${testContacts.length} contacts', name: 'FriendsPage');

      if (testContacts.isEmpty) {
        // If no contacts, try requesting permission explicitly
        developer.log('No contacts found, requesting permission...', name: 'FriendsPage');
        final bool hasPermission = await FlutterContacts.requestPermission();
        developer.log('Permission request result: $hasPermission', name: 'FriendsPage');

        if (!hasPermission) {
          developer.log('Permission denied', name: 'FriendsPage');
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Contact permission is required. Please enable it in settings.';
          });
          return;
        }

        // Try loading contacts again after permission
        developer.log('Retrying contact loading after permission...', name: 'FriendsPage');
        final List<Contact> retryContacts = await FlutterContacts.getContacts();
        developer.log('Retry result: ${retryContacts.length} contacts', name: 'FriendsPage');

        if (retryContacts.isEmpty) {
          developer.log('Still no contacts found', name: 'FriendsPage');
          setState(() {
            _isLoading = false;
            _errorMessage = 'No contacts found on your device.';
          });
          return;
        }
      }

      // Load contacts with properties
      developer.log('Loading contacts with properties...', name: 'FriendsPage');
      final List<Contact> fullContacts = await FlutterContacts.getContacts(
        withProperties: true,
      );
      developer.log('Loaded ${fullContacts.length} contacts with properties', name: 'FriendsPage');

      // Process contacts
      final List<PhoneContact> processedContacts = [];

      for (final contact in fullContacts) {
        final String name = contact.displayName.isNotEmpty
            ? contact.displayName
            : (contact.name.first.isNotEmpty ? contact.name.first : 'Unknown');

        final String? email = contact.emails.isNotEmpty
            ? contact.emails.first.address
            : null;

        final String? phone = contact.phones.isNotEmpty
            ? contact.phones.first.number
            : null;

        // Only add contacts with email or phone
        if (email != null || phone != null) {
          processedContacts.add(
            PhoneContact(
              id: contact.id,
              name: name,
              email: email,
              phoneNumber: phone,
            ),
          );
        }
      }

      developer.log('Processed ${processedContacts.length} contacts with email/phone', name: 'FriendsPage');

      // Sort contacts alphabetically
      processedContacts.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      setState(() {
        _contacts = processedContacts;
        _filteredContacts = List.from(_contacts);
        _isLoading = false;
      });

      developer.log('Contact loading completed successfully', name: 'FriendsPage');
    } catch (e, stackTrace) {
      developer.log('Error loading contacts: $e', name: 'FriendsPage', error: e, stackTrace: stackTrace);

      // Check if it's a permission error
      if (e.toString().contains('permission') ||
          e.toString().contains('denied')) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Contact permission is required. Please enable it in settings.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load contacts: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _handlePermissionDenied() async {
    // Try requesting permission and loading contacts again
    _loadContacts();
  }


  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        return contact.name.toLowerCase().contains(query) ||
            (contact.email?.toLowerCase().contains(query) ?? false) ||
            (contact.phoneNumber?.contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedContacts = _contacts
        .where((contact) => _selectedContactIds.contains(contact.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedContactIds.isEmpty
              ? 'Add Friends'
              : 'Add Friends (${_selectedContactIds.length})',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (!_isLoading && _errorMessage != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'retry') {
                  _loadContacts();
                } else if (value == 'settings') {
                  _handlePermissionDenied();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'retry',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Retry'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone number',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),

          // Selected contacts horizontal list
          if (selectedContacts.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Selected (${selectedContacts.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80, // Increased height to accommodate close button
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        4,
                        16,
                        0,
                      ), // Added top padding for close button
                      itemCount: selectedContacts.length,
                      itemBuilder: (context, index) {
                        final contact = selectedContacts[index];
                        return Container(
                          width: 70,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius:
                                        18, // Slightly smaller to fit better
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    child: Text(
                                      contact.name.isNotEmpty
                                          ? contact.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0, // Moved down to prevent clipping
                                    right: 0, // Moved in slightly
                                    child: GestureDetector(
                                      onTap: () =>
                                          _toggleContactSelection(contact.id),
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Flexible(
                                child: Text(
                                  contact.name,
                                  style: const TextStyle(fontSize: 11),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Error message
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _handlePermissionDenied,
                        icon: const Icon(Icons.settings),
                        label: const Text('Settings'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _loadContacts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Contacts list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading contacts...'),
                      ],
                    ),
                  )
                : _filteredContacts.isEmpty && _errorMessage == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.contacts_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'No contacts found'
                              : 'No contacts available',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Try a different search term'
                              : 'Make sure you have contacts saved on your phone',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      final isSelected = _selectedContactIds.contains(
                        contact.id,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              contact.name.isNotEmpty
                                  ? contact.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (contact.email != null) Text(contact.email!),
                              if (contact.phoneNumber != null)
                                Text(contact.phoneNumber!),
                            ],
                          ),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (value) =>
                                _toggleContactSelection(contact.id),
                          ),
                          onTap: () => _toggleContactSelection(contact.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _selectedContactIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _addSelectedFriends,
              icon: const Icon(Icons.person_add),
              label: Text(
                'Add ${_selectedContactIds.length} Friend${_selectedContactIds.length > 1 ? 's' : ''}',
              ),
            )
          : null,
    );
  }

  void _toggleContactSelection(String contactId) {
    setState(() {
      if (_selectedContactIds.contains(contactId)) {
        _selectedContactIds.remove(contactId);
      } else {
        _selectedContactIds.add(contactId);
      }
    });
  }

  void _addSelectedFriends() {
    final selectedContacts = _contacts
        .where((contact) => _selectedContactIds.contains(contact.id))
        .toList();

    if (selectedContacts.isEmpty) return;

    // Directly add friends without confirmation
    _confirmAddFriends(selectedContacts);
  }

  Future<void> _confirmAddFriends(List<PhoneContact> contacts) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final firestore = FirebaseFirestore.instance;
      final friendsCollection = firestore
          .collection('users')
          .doc(user.uid)
          .collection('friends');

      // Check for existing friends to avoid duplicates
      final existingFriendsSnapshot = await friendsCollection.get();
      final existingEmails = existingFriendsSnapshot.docs
          .map((doc) => (doc.data()['email'] as String?))
          .where((email) => email != null && email.isNotEmpty)
          .toSet();

      final existingPhones = existingFriendsSnapshot.docs
          .map((doc) => (doc.data()['phoneNumber'] as String?))
          .where((phone) => phone != null && phone.isNotEmpty)
          .toSet();

      // Filter out duplicates
      final newContacts = contacts.where((contact) {
        final emailMatch =
            contact.email != null && existingEmails.contains(contact.email);
        final phoneMatch =
            contact.phoneNumber != null &&
            existingPhones.contains(contact.phoneNumber);
        return !emailMatch && !phoneMatch;
      }).toList();

      if (newContacts.isEmpty) {
        // Navigate back without showing notification
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }

      final batch = firestore.batch();

      // Add each new contact as a friend in Firestore
      for (final contact in newContacts) {
        final friend = Friend(
          id: '', // Will be generated by Firestore
          name: contact.name,
          email: contact.email ?? '',
          phoneNumber: contact.phoneNumber,
          addedAt: DateTime.now(),
        );

        final friendRef = friendsCollection.doc(); // Auto-generate ID
        batch.set(friendRef, friend.toFirestore());
      }

      // Commit the batch
      await batch.commit();

      // Navigate back to friends page without showing notification
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      developer.log('Error adding friends: $e', name: 'FriendsPage', error: e);
      // Silently handle errors and navigate back
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}

class PhoneContact {
  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;

  PhoneContact({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
  });
}
