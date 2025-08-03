import 'package:get_it/get_it.dart';
import '../../data/repositories/firebase_group_repository.dart';
import '../../data/repositories/firebase_user_settings_repository.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/repositories/user_settings_repository.dart';
import '../../domain/usecases/create_group.dart';
import '../../domain/usecases/get_user_settings.dart';
import '../../domain/usecases/update_user_settings.dart';
import '../../domain/usecases/initialize_user_settings.dart';
import '../../presentation/bloc/group/group_bloc.dart';
import '../../presentation/bloc/user_settings/user_settings_bloc.dart';
import '../services/auth_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Core services
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // Repositories
  getIt.registerLazySingleton<GroupRepository>(() => FirebaseGroupRepository());
  getIt.registerLazySingleton<UserSettingsRepository>(() => FirebaseUserSettingsRepository());

  // Use cases
  getIt.registerLazySingleton<CreateGroup>(() => CreateGroup(getIt<GroupRepository>()));
  getIt.registerLazySingleton<GetUserSettings>(() => GetUserSettings(getIt<UserSettingsRepository>()));
  getIt.registerLazySingleton<UpdateUserSettings>(() => UpdateUserSettings(getIt<UserSettingsRepository>()));
  getIt.registerLazySingleton<InitializeUserSettings>(() => InitializeUserSettings(getIt<UserSettingsRepository>()));

  // BLoCs - Register as singleton for the app lifecycle
  getIt.registerLazySingleton<GroupBloc>(() => GroupBloc(
        getIt<GroupRepository>(),
        getIt<CreateGroup>(),
      ));
  
  getIt.registerLazySingleton<UserSettingsBloc>(() => UserSettingsBloc(
        getIt<UserSettingsRepository>(),
        getIt<GetUserSettings>(),
        getIt<UpdateUserSettings>(),
        getIt<InitializeUserSettings>(),
      ));
}