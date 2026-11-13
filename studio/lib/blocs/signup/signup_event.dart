part of 'signup_bloc.dart';

@immutable
abstract class SignupEvent {}

class SignupInitialEvent extends SignupEvent {}

class LoginEvent extends SignupEvent {
  final String email;
  final String userPassword;

  LoginEvent(this.email, this.userPassword);
}

class RegisterUser extends SignupEvent {
  final String userName;
  final String email;
  final String password;

  RegisterUser(this.userName, this.email, this.password);
}
