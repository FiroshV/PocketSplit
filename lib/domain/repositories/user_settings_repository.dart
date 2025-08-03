import '../entities/user_settings.dart';

abstract class UserSettingsRepository {
  Future<UserSettings?> getUserSettings(String userId);
  Future<void> createUserSettings(UserSettings userSettings);
  Future<void> updateUserSettings(UserSettings userSettings);
  Future<void> updateBaseCurrency(String userId, String currencyCode);
  Stream<UserSettings?> watchUserSettings(String userId);
}