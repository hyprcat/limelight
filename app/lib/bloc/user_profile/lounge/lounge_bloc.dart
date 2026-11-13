// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/lounge_engine.dart';
import 'package:lime_time_app/logics/models/lounge/lounge.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:meta/meta.dart';

part 'lounge_event.dart';
part 'lounge_state.dart';

class LoungeBloc extends Bloc<LoungeEvent, LoungeState> {
  LoungeBloc() : super(LoungeInitial()) {
    on<LoadLounge>(loadLounge);
  }

  FutureOr<void> loadLounge(LoadLounge event, Emitter<LoungeState> emit) async {
    emit(LoungeLoading());
    try {
      UserLounge? lounge =
          await LoungeEngine().renderLounge(event.user.userId!);
      emit(LoungeSuccess(lounge!));
    } catch (e) {
      emit(LoungeError());
    }
  }
}
