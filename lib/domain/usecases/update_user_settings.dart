import '../entities/user_settings.dart';
import '../repositories/user_settings_repository.dart';

class UpdateUserSettings {
  final UserSettingsRepository repository;

  UpdateUserSettings(this.repository);

  Future<void> call(UserSettings userSettings) async {
    return await repository.updateUserSettings(userSettings);
  }
}