import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_settings.dart';

abstract class UserSettingsEvent extends Equatable {
  const UserSettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserSettingsEvent extends UserSettingsEvent {
  final String userId;

  const LoadUserSettingsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class InitializeUserSettingsEvent extends UserSettingsEvent {
  final String userId;
  final String displayName;
  final String email;
  final String? photoUrl;

  const InitializeUserSettingsEvent({
    required this.userId,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [userId, displayName, email, photoUrl];
}

class UpdateBaseCurrencyEvent extends UserSettingsEvent {
  final String userId;
  final String currencyCode;

  const UpdateBaseCurrencyEvent({
    required this.userId,
    required this.currencyCode,
  });

  @override
  List<Object?> get props => [userId, currencyCode];
}

class UpdateUserSettingsEvent extends UserSettingsEvent {
  final UserSettings userSettings;

  const UpdateUserSettingsEvent(this.userSettings);

  @override
  List<Object?> get props => [userSettings];
}

class UpdateNotificationsEvent extends UserSettingsEvent {
  final String userId;
  final bool enabled;

  const UpdateNotificationsEvent({
    required this.userId,
    required this.enabled,
  });

  @override
  List<Object?> get props => [userId, enabled];
}

class UpdateThemeEvent extends UserSettingsEvent {
  final String userId;
  final String theme;

  const UpdateThemeEvent({
    required this.userId,
    required this.theme,
  });

  @override
  List<Object?> get props => [userId, theme];
}