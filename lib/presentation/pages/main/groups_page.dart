import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocket_split/core/theme/app_theme.dart';
import 'package:pocket_split/core/di/service_locator.dart';
import 'package:pocket_split/core/services/auth_service.dart';
import 'package:pocket_split/core/utils/firestore_config.dart';
import 'package:pocket_split/presentation/pages/groups/create_group_page.dart';
import 'package:pocket_split/presentation/bloc/group/group_bloc.dart';
import 'package:pocket_split/presentation/bloc/group/group_event.dart';
import 'package:pocket_split/presentation/bloc/group/group_state.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  void _navigateToCreateGroup(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateGroupPage(),
      ),
    );
    // If group was created successfully, refresh the groups list
    if (result == true && context.mounted) {
      final currentUser = getIt<AuthService>().currentUser;
      if (currentUser != null) {
        context.read<GroupBloc>().add(LoadUserGroupsEvent(currentUser.uid));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = getIt<GroupBloc>();
        final currentUser = getIt<AuthService>().currentUser;
        if (currentUser != null) {
          bloc.add(LoadUserGroupsEvent(currentUser.uid));
        }
        return bloc;
      },
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Action buttons row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToCreateGroup(context),
                        icon: const Icon(Icons.group_add),
                        label: const Text('Add Group'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.primary2,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to Add Expense screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Add Expense feature coming soon!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Add Expense'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
        
                // Groups list section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Groups',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
        
                      // BLoC builder for groups list
                      Expanded(
                        child: BlocBuilder<GroupBloc, GroupState>(
                          builder: (context, state) {
                            if (state is GroupLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state is GroupsLoaded) {
                              if (state.groups.isEmpty) {
                                return _buildEmptyState(context);
                              }
                              return _buildGroupsList(state.groups);
                            } else if (state is GroupError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Unable to load groups',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 32),
                                      child: Text(
                                        FirestoreConfig.getErrorSolution(state.message),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        OutlinedButton(
                                          onPressed: () {
                                            final currentUser = getIt<AuthService>().currentUser;
                                            if (currentUser != null) {
                                              context.read<GroupBloc>().add(LoadUserGroupsEvent(currentUser.uid));
                                            }
                                          },
                                          child: const Text('Retry'),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton(
                                          onPressed: () => _navigateToCreateGroup(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primary2,
                                            foregroundColor: Colors.black,
                                          ),
                                          child: const Text('Create First Group'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                            return _buildEmptyState(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No groups yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first group to start splitting expenses with friends',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateGroup(context),

            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              'Create Group',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: AppTheme.primary2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList(List<dynamic> groups) {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary2,
              child: Icon(
                _getGroupTypeIcon(group.type),
                color: Colors.black,
              ),
            ),
            title: Text(
              group.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${group.memberIds.length} member${group.memberIds.length == 1 ? '' : 's'}'),
                Text(
                  'Created ${_formatDate(group.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  group.type,
                  style: TextStyle(
                    color: AppTheme.secondary2,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  group.currency,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () {
              // TODO: Navigate to group detail page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Viewing ${group.name} - Coming soon!'),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getGroupTypeIcon(String type) {
    switch (type) {
      case 'Trip':
        return Icons.luggage;
      case 'Home':
        return Icons.home;
      case 'Couple':
        return Icons.favorite;
      case 'Other':
      default:
        return Icons.group;
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
}
