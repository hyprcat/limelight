import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:meta/meta.dart';

import 'package:lime_time_app/defaults/utils.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc() : super(LeaderboardInitial()) {
    on<LoadLeaderboard>(load, transformer: debounce());
  }

  UserRepo repo = UserRepo();
  FutureOr<void> load(
      LoadLeaderboard event, Emitter<LeaderboardState> emit) async {
    try {
      if (event.isDay) {
        repo = await UserEngine().getTopUsersDay(repo, event.data);
      } else if (event.isWeek) {
        repo = await UserEngine().getTopUsersWeek(repo, event.data);
      } else if (event.isMonth) {
        repo = await UserEngine().getTopUsersMonth(repo, event.data);
      }
      emit(LoadedLeaderboards(repo: repo));
    } catch (e) {
      emit(LeaderboardsError());
    }
  }
}
