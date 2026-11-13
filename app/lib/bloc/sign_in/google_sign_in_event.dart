part of 'google_sign_in_bloc.dart';

@immutable
abstract class GoogleSignInEvent {}

class LoadPage extends GoogleSignInEvent {}

class LoadPageApple extends GoogleSignInEvent {}

class SignInStart extends GoogleSignInEvent {}

class RegisterUser extends GoogleSignInEvent {
  final String userName;
  final String email;
  final String password;

  RegisterUser(this.userName, this.email, this.password);
}

class LoginEvent extends GoogleSignInEvent {
  final String email;
  final String userPassword;

  LoginEvent(this.email, this.userPassword);
}
