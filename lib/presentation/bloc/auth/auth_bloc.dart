import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../domain/usecases/initialize_user_settings.dart';
import '../../../core/di/service_locator.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'dart:developer' as developer;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  late StreamSubscription<User?> _authSubscription;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthUserChanged>(_onAuthUserChanged);

    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen((user) {
      add(AuthUserChanged(user));
    });

    // Check initial auth state
    add(AuthCheckRequested());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = _authService.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential?.user != null) {
        // Initialize user settings
        try {
          final initializeUserSettings = getIt<InitializeUserSettings>();
          await initializeUserSettings(
            userId: userCredential!.user!.uid,
            displayName: userCredential.user!.displayName ?? 'User',
            email: userCredential.user!.email ?? '',
            photoUrl: userCredential.user!.photoURL,
          );
          developer.log('User settings initialized successfully', name: 'AuthBloc');
        } catch (e) {
          developer.log('Failed to initialize user settings: $e', name: 'AuthBloc', error: e);
          // Continue anyway, settings can be created later
        }
        
        emit(AuthAuthenticated(userCredential!.user!));
      } else {
        // Sign-in was cancelled
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      await _authService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;
    if (user != null && user is User) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}