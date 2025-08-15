import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocket_split/core/theme/app_theme.dart';
import 'package:pocket_split/core/di/service_locator.dart';
import 'package:pocket_split/core/services/auth_service.dart';
import 'package:pocket_split/core/constants/currencies.dart';
import 'package:pocket_split/core/services/currency_location_service.dart';
import 'package:pocket_split/core/utils/currency_utils.dart';
import 'package:pocket_split/presentation/bloc/user_settings/user_settings_bloc.dart';
import 'package:pocket_split/presentation/bloc/user_settings/user_settings_event.dart';
import 'package:pocket_split/presentation/bloc/user_settings/user_settings_state.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = getIt<UserSettingsBloc>();
        final currentUser = getIt<AuthService>().currentUser;
        if (currentUser != null) {
          // Only load existing settings, don't force currency detection
          // Let the user manually select their preferred currency
          bloc.add(LoadUserSettingsEvent(currentUser.uid));
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocListener<UserSettingsBloc, UserSettingsState>(
          listenWhen: (previous, current) {
            // Only listen to error states to avoid unnecessary rebuilds
            return current is UserSettingsError;
          },
          listener: (context, state) {
            if (state is UserSettingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );

              // Try to initialize settings if they don't exist
              final currentUser = getIt<AuthService>().currentUser;
              if (currentUser != null && state.message.contains('not found')) {
                context.read<UserSettingsBloc>().add(
                  InitializeUserSettingsEvent(
                    userId: currentUser.uid,
                    displayName: currentUser.displayName ?? 'User',
                    email: currentUser.email ?? '',
                    photoUrl: currentUser.photoURL,
                  ),
                );
              }
            }
          },
          child: BlocBuilder<UserSettingsBloc, UserSettingsState>(
            buildWhen: (previous, current) {
              // Don't rebuild the main page on BaseCurrencyUpdated - let individual widgets handle it
              if (current is BaseCurrencyUpdated) return false;
              
              // Only rebuild on initial load and errors
              return current is UserSettingsLoaded || 
                     current is UserSettingsLoading || 
                     current is UserSettingsError;
            },
            builder: (context, state) {
              if (state is UserSettingsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

            final currentUser = getIt<AuthService>().currentUser;
            final userSettings = state is UserSettingsLoaded
                ? state.userSettings
                : null;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile section
                  _buildProfileSection(context, currentUser, userSettings),

                  const SizedBox(height: 24),

                  // Settings list
                  Expanded(
                    child: ListView(
                      children: [
                        // Currency Settings Section
                        _buildSectionHeader(context, 'Preferences'),
                        _buildCurrencyTile(context, userSettings),
                        _buildSettingsTile(
                          context,
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          trailing: userSettings?.notificationsEnabled == true
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () =>
                              _toggleNotifications(context, userSettings),
                        ),

                        // _buildSettingsTile(
                        //   context,
                        //   icon: Icons.palette_outlined,
                        //   title: 'Theme',
                        //   subtitle: _getThemeDisplayName(
                        //     userSettings?.theme ?? 'system',
                        //   ),
                        //   onTap: () =>
                        //       _showThemeSelector(context, userSettings),
                        // ),

                        const SizedBox(height: 16),
                        _buildSectionHeader(context, 'Support'),

                        _buildSettingsTile(
                          context,
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          onTap: () => _showComingSoon(context),
                        ),
                        _buildSettingsTile(
                          context,
                          icon: Icons.info_outline,
                          title: 'About',
                          onTap: () => _showComingSoon(context),
                        ),

                        const SizedBox(height: 16),
                        _buildSectionHeader(context, 'Account'),

                        _buildSettingsTile(
                          context,
                          icon: Icons.security_outlined,
                          title: 'Privacy & Security',
                          onTap: () => _showComingSoon(context),
                        ),

                        _buildSettingsTile(
                          context,
                          icon: Icons.logout,
                          title: 'Sign Out',
                          isDestructive: true,
                          onTap: () => _showComingSoon(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, currentUser, userSettings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: currentUser?.photoURL != null
                ? NetworkImage(currentUser!.photoURL!)
                : null,
            backgroundColor: AppTheme.primary2,
            child: currentUser?.photoURL == null
                ? const Icon(Icons.person, size: 30, color: Colors.black)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userSettings?.displayName ??
                      currentUser?.displayName ??
                      'User',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  userSettings?.email ?? currentUser?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (userSettings?.baseCurrency != null) ...[
                  const SizedBox(height: 4),
                  BlocBuilder<UserSettingsBloc, UserSettingsState>(
                    buildWhen: (previous, current) {
                      // Rebuild on currency changes and when settings are loaded/updated
                      if (previous is UserSettingsLoaded && current is UserSettingsLoaded) {
                        return previous.userSettings.baseCurrency != current.userSettings.baseCurrency;
                      }
                      return current is UserSettingsLoaded || current is BaseCurrencyUpdated;
                    },
                    builder: (context, state) {
                      String? currency;
                      if (state is BaseCurrencyUpdated) {
                        currency = state.currencyCode;
                      } else if (state is UserSettingsLoaded) {
                        currency = state.userSettings.baseCurrency;
                      } else {
                        currency = userSettings?.baseCurrency;
                      }
                      
                      return Text(
                        'Base Currency: $currency',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondary2,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showComingSoon(context),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppTheme.secondary2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCurrencyTile(BuildContext context, userSettings) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      buildWhen: (previous, current) {
        // Rebuild on currency changes and when settings are loaded/updated
        if (previous is UserSettingsLoaded && current is UserSettingsLoaded) {
          return previous.userSettings.baseCurrency != current.userSettings.baseCurrency;
        }
        return current is UserSettingsLoaded || current is BaseCurrencyUpdated;
      },
      builder: (context, state) {
        dynamic currentSettings = userSettings;
        String? currencyCode;
        
        if (state is BaseCurrencyUpdated) {
          currencyCode = state.currencyCode;
          currentSettings = userSettings; // Use the existing userSettings as base
        } else if (state is UserSettingsLoaded) {
          currentSettings = state.userSettings;
          currencyCode = currentSettings?.baseCurrency;
        } else {
          currencyCode = userSettings?.baseCurrency;
        }
        
        final currency = currencyCode != null
            ? CurrencyConstants.getCurrencyByCode(currencyCode)
            : null;

        return ListTile(
          leading: const Icon(Icons.attach_money),
          title: const Text('Base Currency'),
          subtitle: currency != null
              ? Text('${currency.symbol} ${currency.code} - ${currency.name}')
              : const Text('Tap to set your preferred currency'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showCurrencySelector(context, currentSettings),
        );
      },
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : null),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showCurrencySelector(BuildContext context, userSettings) {
    // Check if user settings are loaded before showing the bottom sheet
    final currentState = context.read<UserSettingsBloc>().state;
    debugPrint('💰 Opening currency selector, current state: ${currentState.runtimeType}');
    
    if (currentState is! UserSettingsLoaded && currentState is! BaseCurrencyUpdated) {
      debugPrint('⚠️ User settings not loaded, reloading...');
      final currentUser = getIt<AuthService>().currentUser;
      if (currentUser != null) {
        context.read<UserSettingsBloc>().add(LoadUserSettingsEvent(currentUser.uid));
      }
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<UserSettingsBloc>(),
          child: _CurrencySelectorBottomSheet(userSettings: userSettings),
        );
      },
    );
  }

  void _toggleNotifications(BuildContext context, userSettings) {
    final currentUser = getIt<AuthService>().currentUser;
    if (currentUser != null && userSettings != null) {
      context.read<UserSettingsBloc>().add(
        UpdateNotificationsEvent(
          userId: currentUser.uid,
          enabled: !userSettings.notificationsEnabled,
        ),
      );
    }
  }




  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Feature coming soon!')));
  }
}

class _CurrencySelectorBottomSheet extends StatefulWidget {
  final dynamic userSettings;

  const _CurrencySelectorBottomSheet({required this.userSettings});

  @override
  State<_CurrencySelectorBottomSheet> createState() =>
      _CurrencySelectorBottomSheetState();
}

class _CurrencySelectorBottomSheetState
    extends State<_CurrencySelectorBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Currency> _filteredCurrencies = [];
  String? _detectedCurrency;
  String? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = CurrencyConstants.supportedCurrencies;
    _searchController.addListener(_onSearchChanged);
    // Get detected currency once during initialization
    _detectedCurrency = CurrencyLocationService.getDetectedCurrency();
    // Initialize selected currency
    _selectedCurrency = widget.userSettings?.baseCurrency;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCurrencies = CurrencyConstants.supportedCurrencies.where((
        currency,
      ) {
        return currency.code.toLowerCase().contains(query) ||
            currency.name.toLowerCase().contains(query) ||
            currency.country.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _testUserCurrencySymbol() async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text('Detecting currency from location...'),
          ],
        ),
        duration: Duration(seconds: 5),
      ),
    );

    try {
      // Get both locale-based and location-based symbols
      final localeSymbol = CurrencyUtils.getCurrencySymbol();
      debugPrint('🔍 Starting location detection test...');

      // Clear cache to force fresh detection
      CurrencyLocationService.clearCache();

      // Get detailed location info for debugging
      final locationCurrency =
          await CurrencyLocationService.detectCurrencyFromLocation();
      debugPrint('🌍 Location service returned: $locationCurrency');

      final locationSymbol =
          await CurrencyUtils.getCurrencySymbolFromLocation();

      debugPrint('📍 Locale-based currency symbol: $localeSymbol');
      debugPrint('🛰️ Location-based currency symbol: $locationSymbol');

      // Get more detailed debug info
      final localeInfo = Platform.localeName;
      final detectedFromService = CurrencyLocationService.getDetectedCurrency();

      debugPrint('🔧 Debug info:');
      debugPrint('   - Platform.localeName: $localeInfo');
      debugPrint('   - Service detected currency: $detectedFromService');

      // Check if widget is still mounted before showing dialog
      if (!mounted) return;

      // Show results dialog with more details
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Currency Detection Results'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Locale-based (Language): $localeSymbol',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location-based (GPS/IP): $locationSymbol',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: localeSymbol != locationSymbol
                          ? AppTheme.secondary2
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Debug Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Platform Locale: $localeInfo',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'Service Result: $detectedFromService',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'Location Currency: $locationCurrency',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (localeSymbol != locationSymbol) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary1.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Location-based detection found a different currency than your language preference!',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Error testing currency symbols: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error detecting currency: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserSettingsBloc, UserSettingsState>(
      listener: (context, state) {
        debugPrint('🔔 Bottom sheet listener received state: ${state.runtimeType}');
        
        if (state is BaseCurrencyUpdated) {
          // Don't close the bottom sheet - keep it open for better UX
          debugPrint(
            '✅ Currency updated successfully to ${state.currencyCode}',
          );
          // Update local state to reflect the change
          setState(() {
            _selectedCurrency = state.currencyCode;
          });
        } else if (state is UserSettingsError) {
          // Show error but don't close
          debugPrint('❌ Currency update failed: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update currency: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is UserSettingsLoaded) {
          // Update the current currency when settings are reloaded
          debugPrint('📋 Settings loaded, currency: ${state.userSettings.baseCurrency}');
          setState(() {
            _selectedCurrency = state.userSettings.baseCurrency;
          });
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select Base Currency',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This will be your default currency for new groups',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search currencies...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                        _searchController.clear();
                                      },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Test Currency Symbol Button
                    ElevatedButton.icon(
                      onPressed: _testUserCurrencySymbol,
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Check My Currency Symbol'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary1,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Currency List
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _filteredCurrencies.length,
                        itemBuilder: (context, index) {
                          final currency = _filteredCurrencies[index];
                          final isSelected = _selectedCurrency == currency.code;
                          final isDetected =
                              _detectedCurrency != null &&
                              _detectedCurrency == currency.code;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                    debugPrint(
                                      '🎯 Currency selected: ${currency.code}',
                                    );
                                    
                                    // Update UI immediately for instant feedback
                                    setState(() {
                                      _selectedCurrency = currency.code;
                                    });
                                    
                                    final currentUser =
                                        getIt<AuthService>().currentUser;
                                    if (currentUser != null) {
                                      // Check current BLoC state before sending event
                                      final currentState = context.read<UserSettingsBloc>().state;
                                      debugPrint('🔍 Current BLoC state: ${currentState.runtimeType}');
                                      
                                      if (currentState is UserSettingsLoaded || currentState is BaseCurrencyUpdated) {
                                        debugPrint(
                                          '📤 Sending UpdateBaseCurrencyEvent for ${currency.code}',
                                        );
                                        context.read<UserSettingsBloc>().add(
                                          UpdateBaseCurrencyEvent(
                                            userId: currentUser.uid,
                                            currencyCode: currency.code,
                                          ),
                                        );
                                      } else {
                                        debugPrint('❌ BLoC state is not loaded: ${currentState.runtimeType}');
                                        // Try to reload user settings first
                                        context.read<UserSettingsBloc>().add(
                                          LoadUserSettingsEvent(currentUser.uid),
                                        );
                                      }
                                    } else {
                                      debugPrint('❌ No current user found');
                                      Navigator.pop(context);
                                    }
                                  },
                              child: ListTile(
                              leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? AppTheme.primary2
                                  : Colors.grey.shade200,
                              child: Text(
                                currency.symbol,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              '${currency.code} - ${currency.name}',
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(currency.country),
                                if (isDetected) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary1.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Detected',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.secondary2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: AppTheme.secondary2,
                                  )
                                : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
        },
      ),
    );
  }
}
