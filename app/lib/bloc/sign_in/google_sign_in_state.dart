part of 'google_sign_in_bloc.dart';

@immutable
abstract class GoogleSignInState {}

class GoogleSignInInitial extends GoogleSignInState {}

class LoadingStart extends GoogleSignInState {}

class GoogleSignInSuccess extends GoogleSignInState {}

class AppleSignInSuccess extends GoogleSignInState {}

class SignInSuccess extends GoogleSignInState {}

class SignInError extends GoogleSignInState {
  final String error;

  SignInError({required this.error});
}

class MSignInError extends GoogleSignInState {
  final String error;

  MSignInError({required this.error});
}
