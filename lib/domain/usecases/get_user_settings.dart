import '../entities/user_settings.dart';
import '../repositories/user_settings_repository.dart';

class GetUserSettings {
  final UserSettingsRepository repository;

  GetUserSettings(this.repository);

  Future<UserSettings?> call(String userId) async {
    return await repository.getUserSettings(userId);
  }
}