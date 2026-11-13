// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:code_arrow_creator_studio/engines/user_engine.dart';
import 'package:meta/meta.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupInitial()) {
    on<SignupInitialEvent>(signUpLoad);
    on<LoginEvent>(login);
    on<RegisterUser>(register);
  }

  FutureOr<void> login(LoginEvent event, Emitter<SignupState> emit) async {
    emit(SignupLoading());
    try {
      Map<String, String> data = {'email': event.email, 'password': event.userPassword};
      await UserEngine().login(data);
      emit(LoginSuccess());
    } catch (e) {
      emit(SignupError(e.toString()));
    }
  }

  FutureOr<void> register(RegisterUser event, Emitter<dynamic> emit) async {
    emit(SignupLoading());
    try {
      Map<String, String> data = {
        'user_name': event.userName,
        'user_email': event.email,
        'password': event.password,
        'user_password': event.password,
      };

      Map<String, String> loginData = {'email': event.email, 'password': event.password};
      String response = await UserEngine().createUser(data);

      if (response == "user successfully created.") {
        await UserEngine().login(loginData);
        emit(SignupSuccess());
      } else {
        emit(SignupError(response));
      }
    } catch (e) {
      emit(SignupError(e.toString()));
    }
  }

  FutureOr<void> signUpLoad(SignupInitialEvent event, Emitter<SignupState> emit) async {
    emit(LoginState());
  }
}
