import 'package:get_it/get_it.dart';
import '../../data/repositories/firebase_group_repository.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/usecases/create_group.dart';
import '../../presentation/bloc/group/group_bloc.dart';
import '../services/auth_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Core services
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // Repositories
  getIt.registerLazySingleton<GroupRepository>(() => FirebaseGroupRepository());

  // Use cases
  getIt.registerLazySingleton<CreateGroup>(() => CreateGroup(getIt<GroupRepository>()));

  // BLoCs - Register as singleton for the app lifecycle
  getIt.registerLazySingleton<GroupBloc>(() => GroupBloc(
        getIt<GroupRepository>(),
        getIt<CreateGroup>(),
      ));
}