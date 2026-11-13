import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:meta/meta.dart';

part 'subscribed_to_event.dart';
part 'subscribed_to_state.dart';

class SubscribedToBloc extends Bloc<SubscribedToEvent, SubscribedToState> {
  SubscribedToBloc() : super(SubscribedToInitial()) {
    on<LoadSubscribedTo>(load);
    on<LoadBlockedUsers>(loadBlocked);
  }

  UserRepo repo = UserRepo();
  FutureOr<void> load(
      LoadSubscribedTo event, Emitter<SubscribedToState> emit) async {
    try {
      repo = await UserEngine().fetchSubscribedUsers(repo);
      emit(LoadingSuccess(repo: repo));
    } catch (e) {
      rethrow;
    }
  }

  FutureOr<void> loadBlocked(
      LoadBlockedUsers event, Emitter<SubscribedToState> emit) async {
    try {
      repo = await UserEngine().fetchBlockedUsers(repo);
      emit(LoadingSuccess(repo: repo));
    } catch (e) {
      rethrow;
    }
  }
}
