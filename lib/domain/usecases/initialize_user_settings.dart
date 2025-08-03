import 'package:flutter/foundation.dart';
import '../entities/user_settings.dart';
import '../repositories/user_settings_repository.dart';
import '../../core/services/currency_location_service.dart';

class InitializeUserSettings {
  final UserSettingsRepository repository;

  InitializeUserSettings(this.repository);

  Future<UserSettings> call({
    required String userId,
    required String displayName,
    required String email,
    String? photoUrl,
  }) async {
    debugPrint('InitializeUserSettings: Starting initialization for user $userId');
    
    // Check if user settings already exist
    final existingSettings = await repository.getUserSettings(userId);
    if (existingSettings != null) {
      debugPrint('InitializeUserSettings: Existing settings found, returning them (currency: ${existingSettings.baseCurrency})');
      return existingSettings;
    }

    debugPrint('InitializeUserSettings: No existing settings found, creating new ones');
    
    // Detect currency from location
    debugPrint('InitializeUserSettings: Starting currency detection...');
    final detectedCurrency = await CurrencyLocationService.detectCurrencyFromLocation();
    debugPrint('InitializeUserSettings: Currency detection completed: $detectedCurrency');

    // Create new user settings with detected currency
    final userSettings = UserSettings(
      userId: userId,
      baseCurrency: detectedCurrency,
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      notificationsEnabled: true,
      theme: 'system',
      language: 'en',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('InitializeUserSettings: Creating user settings with currency: $detectedCurrency');
    await repository.createUserSettings(userSettings);
    debugPrint('InitializeUserSettings: User settings created successfully');
    
    return userSettings;
  }
}