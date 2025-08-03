import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_settings.dart';

abstract class UserSettingsState extends Equatable {
  const UserSettingsState();

  @override
  List<Object?> get props => [];
}

class UserSettingsInitial extends UserSettingsState {}

class UserSettingsLoading extends UserSettingsState {}

class UserSettingsLoaded extends UserSettingsState {
  final UserSettings userSettings;

  const UserSettingsLoaded(this.userSettings);

  @override
  List<Object?> get props => [userSettings];
}

class UserSettingsUpdated extends UserSettingsState {
  final UserSettings userSettings;

  const UserSettingsUpdated(this.userSettings);

  @override
  List<Object?> get props => [userSettings];
}

class BaseCurrencyUpdated extends UserSettingsState {
  final String currencyCode;

  const BaseCurrencyUpdated(this.currencyCode);

  @override
  List<Object?> get props => [currencyCode];
}

class UserSettingsError extends UserSettingsState {
  final String message;

  const UserSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}