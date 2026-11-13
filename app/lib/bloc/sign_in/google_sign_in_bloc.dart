// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/defaults/global.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/main.dart';
import 'package:meta/meta.dart';

part 'google_sign_in_event.dart';
part 'google_sign_in_state.dart';

class GoogleSignInBloc extends Bloc<GoogleSignInEvent, GoogleSignInState> {
  GoogleSignInBloc() : super(GoogleSignInInitial()) {
    on<LoadPageApple>(loadPageApple);
    on<LoadPage>(loadPage);
    on<SignInStart>(startProcess);
    on<LoginEvent>(login);
    on<RegisterUser>(register);
  }

  FutureOr<void> startProcess(
      SignInStart event, Emitter<GoogleSignInState> emit) async {
    emit(LoadingStart());
    try {
      await authHandler.signInWithGoogle();
      User? user = authHandler.getUser();
      if (user != null) {
        emit(GoogleSignInSuccess());
        await authHandler.handleLimeSignIn();
        emit(SignInSuccess());
      } else {
        emit(SignInError(error: "Couldn't get user"));
      }
    } catch (e) {
      emit(SignInError(error: e.toString()));
    }
  }

  FutureOr<void> register(
      RegisterUser event, Emitter<GoogleSignInState> emit) async {
    emit(LoadingStart());
    try {
      Map<String, String> data = {
        'user_name': event.userName,
        'user_email': event.email,
        'password': event.password,
        'user_password': event.password,
      };

      Map<String, String> loginData = {
        'email': event.email,
        'password': event.password
      };
      cachedNewData = loginData;
      String response = await UserEngine().createUser(data);
      if (response == "user successfully created.") {
        await UserEngine().partialLogin(loginData);
        analytics!.logLogin(loginMethod: 'email');
        emit(SignInSuccess());
      } else {
        emit(MSignInError(error: response));
      }
    } catch (e) {
      emit(MSignInError(error: e.toString()));
    }
  }

  FutureOr<void> login(
      LoginEvent event, Emitter<GoogleSignInState> emit) async {
    emit(LoadingStart());
    try {
      Map<String, String> data = {
        'email': event.email,
        'password': event.userPassword
      };
      await UserEngine().login(data);
      emit(SignInSuccess());
    } catch (e) {
      emit(MSignInError(error: e.toString()));
    }
  }

  FutureOr<void> loadPage(LoadPage event, Emitter<GoogleSignInState> emit) {
    emit(GoogleSignInInitial());
  }

  FutureOr<void> loadPageApple(
      LoadPageApple event, Emitter<GoogleSignInState> emit) async {
    emit(LoadingStart());
    try {
      final credential = await authHandler.signInWithApple();
      if (credential != null) {
        emit(AppleSignInSuccess());
        await UserEngine().handleAppleSignIn(credential.identityToken);
        emit(SignInSuccess());
      } else {
        emit(SignInError(error: "Couldn't get user"));
      }
    } catch (e) {
      rethrow;
    }
  }
}
