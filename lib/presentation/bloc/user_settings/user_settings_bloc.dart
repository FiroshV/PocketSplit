import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user_settings.dart';
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
  
  // Keep track of the last loaded user settings
  UserSettings? _lastLoadedSettings;

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
        _lastLoadedSettings = userSettings; // Store the loaded settings
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
      _lastLoadedSettings = userSettings; // Store the initialized settings
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
      UserSettings? settingsToUpdate;
      
      if (currentState is UserSettingsLoaded) {
        settingsToUpdate = currentState.userSettings;
      } else if (currentState is BaseCurrencyUpdated && _lastLoadedSettings != null) {
        // Use the last loaded settings when current state is BaseCurrencyUpdated
        settingsToUpdate = _lastLoadedSettings;
      }
      
      if (settingsToUpdate != null) {
        debugPrint('🔄 Updating currency from ${settingsToUpdate.baseCurrency} to ${event.currencyCode}');
        
        // Update database first
        await _userSettingsRepository.updateBaseCurrency(
          event.userId,
          event.currencyCode,
        );
        
        debugPrint('✅ Database updated successfully');
        
        // Update local state
        final updatedSettings = settingsToUpdate.copyWith(
          baseCurrency: event.currencyCode,
          updatedAt: DateTime.now(),
        );
        
        // Update the stored settings
        _lastLoadedSettings = updatedSettings;
        
        // Emit updated state
        emit(UserSettingsLoaded(updatedSettings));
        // Emit specific currency update event for UI feedback
        emit(BaseCurrencyUpdated(event.currencyCode));
        
        debugPrint('🎯 State updated: ${updatedSettings.baseCurrency}');
      } else {
        debugPrint('❌ Cannot update currency - no loaded state or stored settings');
        emit(UserSettingsError('User settings not loaded'));
      }
    } catch (e) {
      debugPrint('❌ Error updating currency: $e');
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
      _lastLoadedSettings = event.userSettings; // Store the updated settings
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
        _lastLoadedSettings = updatedSettings; // Store the updated settings
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
        _lastLoadedSettings = updatedSettings; // Store the updated settings
        emit(UserSettingsLoaded(updatedSettings));
      }
    } catch (e) {
      emit(UserSettingsError('Failed to update theme: ${e.toString()}'));
    }
  }
}