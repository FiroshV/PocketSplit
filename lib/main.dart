import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocket_split/core/theme/app_theme.dart';
import 'package:pocket_split/core/di/service_locator.dart';
import 'package:pocket_split/core/utils/firestore_config.dart';
import 'package:pocket_split/core/services/auth_service.dart';
import 'package:pocket_split/presentation/bloc/auth/auth_bloc.dart';
import 'package:pocket_split/presentation/bloc/auth/auth_wrapper.dart';
import 'package:pocket_split/presentation/bloc/user_settings/user_settings_bloc.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configure Firestore for optimal performance
  FirestoreConfig.configureForDevelopment();
  
  setupServiceLocator();
  runApp(const PocketSplitApp());
}

class PocketSplitApp extends StatelessWidget {
  const PocketSplitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(getIt<AuthService>()),
        ),
        BlocProvider<UserSettingsBloc>(
          create: (context) => getIt<UserSettingsBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'PocketSplit',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

