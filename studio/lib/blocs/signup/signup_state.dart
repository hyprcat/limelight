part of 'signup_bloc.dart';

@immutable
abstract class SignupState {}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class LoginState extends SignupState {}

class Register extends SignupState {}

class LoginSuccess extends SignupState {}

class SignupSuccess extends SignupState {}

class SignupError extends SignupState {
  final String error;

  SignupError(this.error);
}
