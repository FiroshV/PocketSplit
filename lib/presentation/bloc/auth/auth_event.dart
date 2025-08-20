import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final dynamic user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}