import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/lounge_engine.dart';
import 'package:lime_time_app/logics/repos/lounge_home.dart';
import 'package:meta/meta.dart';

part 'lounge_home_event.dart';
part 'lounge_home_state.dart';

class LoungeHomeBloc extends Bloc<LoungeHomeEvent, LoungeHomeState> {
  LoungeHomeBloc() : super(LoungeHomeInitial()) {
    on<LoadLoungeHome>(loadLoungeHome);
  }

  FutureOr<void> loadLoungeHome(
      LoadLoungeHome event, Emitter<LoungeHomeState> emit) async {
    emit(LoadingLoungeHome());
    LoungeHome? loungeHome = await LoungeEngine().renderLoungeHome();
    emit(LoungeHomeSuccess(loungeHome!));
  }
}
