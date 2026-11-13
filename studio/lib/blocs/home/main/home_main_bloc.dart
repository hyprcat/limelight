// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:code_arrow_creator_studio/engines/models/user_profile.dart';
import 'package:code_arrow_creator_studio/engines/user_engine.dart';
import 'package:code_arrow_creator_studio/main.dart';
import 'package:meta/meta.dart';

part 'home_main_event.dart';
part 'home_main_state.dart';

class HomeMainBloc extends Bloc<HomeMainEvent, HomeMainState> {
  HomeMainBloc() : super(HomeMainInitial()) {
    on<HomeMainLoading>(start);
  }

  FutureOr<void> start(HomeMainLoading event, Emitter<HomeMainState> emit) async {
    emit(HomeLoadingState());
    try {
      sessionData = await storage.readAll();
      UserProfile obj = await UserEngine().getLoggedInUser();
      emit(HomeLoadSuccess(obj));
    } catch (e) {
      emit(HomeError());
    }
  }
}
