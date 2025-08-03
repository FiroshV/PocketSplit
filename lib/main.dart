import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pocket_split/core/theme/app_theme.dart';
import 'package:pocket_split/presentation/pages/auth/sign_in_screen.dart';
import 'package:pocket_split/core/di/service_locator.dart';
import 'package:pocket_split/core/utils/firestore_config.dart';

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
    return MaterialApp(
      title: 'PocketSplit',
      theme: AppTheme.lightTheme,
      home: const SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

