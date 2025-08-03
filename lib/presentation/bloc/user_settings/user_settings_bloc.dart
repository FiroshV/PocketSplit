import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/user_settings_repository.dart';
import '../../../domain/usecases/get_user_settings.dart';
import '../../../domain/usecases/update_user_settings.dart';
import '../../../domain/usecases/initialize_user_settings.dart';
import 'user_settings_event.dart';
import 'user_settings_state.dart';

class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  final UserSettingsRepository _userSettingsRepository;
  final GetUserSettings _getUserSettings;
  final UpdateUserSettings _updateUserSettings;
  final InitializeUserSettings _initializeUserSettings;

  UserSettingsBloc(
    this._userSettingsRepository,
    this._getUserSettings,
    this._updateUserSettings,
    this._initializeUserSettings,
  ) : super(UserSettingsInitial()) {
    on<LoadUserSettingsEvent>(_onLoadUserSettings);
    on<InitializeUserSettingsEvent>(_onInitializeUserSettings);
    on<UpdateBaseCurrencyEvent>(_onUpdateBaseCurrency);
    on<UpdateUserSettingsEvent>(_onUpdateUserSettings);
    on<UpdateNotificationsEvent>(_onUpdateNotifications);
    on<UpdateThemeEvent>(_onUpdateTheme);
  }

  Future<void> _onLoadUserSettings(
    LoadUserSettingsEvent event,
    Emitter<UserSettingsState> emit,
  ) async {
    try {
      emit(UserSettingsLoading());
      final userSettings = await _getUserSettings(event.userId);
      
      if (userSettings != null) {
        emit(UserSettingsLoaded(userSettings));
      } else {
        emit(const UserSettingsError('User settings not found'));
      }
    } catch (e) {
      emit(UserSettingsError('Failed to load user settings: ${e.toString()}'));
    }
  }

  Future<void> _onInitializeUserSettings(
    InitializeUserSettingsEvent event,
    Emitter<UserSettingsState> emit,
  ) async {
    try {
      emit(UserSettingsLoading());
      final userSettings = await _initializeUserSettings(
        userId: event.userId,
        displayName: event.displayName,
        email: event.email,
        photoUrl: event.photoUrl,
      );
      emit(UserSettingsLoaded(userSettings));
    } catch (e) {
      emit(UserSettingsError('Failed to initialize user settings: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateBaseCurrency(
    UpdateBaseCurrencyEvent event,
    Emitter<UserSettingsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserSettingsLoaded) {
        emit(UserSettingsLoading());
        
        await _userSettingsRepository.updateBaseCurrency(
          event.userId,
          event.currencyCode,
        );
        
        final updatedSettings = currentState.userSettings.copyWith(
          baseCurrency: event.currencyCode,
          updatedAt: DateTime.now(),
        );
        
        emit(UserSettingsLoaded(updatedSettings));
        emit(BaseCurrencyUpdated(event.currencyCode));
      }
    } catch (e) {
      emit(UserSettingsError('Failed to update base currency: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUserSettings(
    UpdateUserSettingsEvent event,
    Emitter<UserSettingsState> emit,
  ) async {
    try {
      emit(UserSettingsLoading());
      await _updateUserSettings(event.userSettings);
      emit(UserSettingsLoaded(event.userSettings));
      emit(UserSettingsUpdated(event.userSettings));
    } catch (e) {
      emit(UserSettingsError('Failed to update user settings: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNotifications(
    UpdateNotificationsEvent event,
    Emitter<UserSettingsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserSettingsLoaded) {
        final updatedSettings = currentState.userSettings.copyWith(
          notificationsEnabled: event.enabled,
          updatedAt: DateTime.now(),
        );
        
        emit(UserSettingsLoading());
        await _updateUserSettings(updatedSettings);
        emit(UserSettingsLoaded(updatedSettings));
      }
    } catch (e) {
      emit(UserSettingsError('Failed to update notifications: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTheme(
    UpdateThemeEvent event,
    Emitter<UserSettingsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserSettingsLoaded) {
        final updatedSettings = currentState.userSettings.copyWith(
          theme: event.theme,
          updatedAt: DateTime.now(),
        );
        
        emit(UserSettingsLoading());
        await _updateUserSettings(updatedSettings);
        emit(UserSettingsLoaded(updatedSettings));
      }
    } catch (e) {
      emit(UserSettingsError('Failed to update theme: ${e.toString()}'));
    }
  }
}