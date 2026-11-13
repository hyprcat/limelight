import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'leaderboard_home_event.dart';
part 'leaderboard_home_state.dart';

class LeaderboardHomeBloc
    extends Bloc<LeaderboardHomeEvent, LeaderboardHomeState> {
  LeaderboardHomeBloc() : super(LeaderboardHomeInitial()) {
    on<LoadLeaderboardHome>(load);
  }

  FutureOr<void> load(
      LoadLeaderboardHome event, Emitter<LeaderboardHomeState> emit) async {
    emit(LeaderboardHomeInitial());
    await Future.delayed(const Duration(milliseconds: 5));
    emit(LeaderboardHomeSuccess(
      city: event.city,
      country: event.country,
      categoryId: event.categoryId,
      region: event.region,
      isDay: event.isDay,
      isWeek: event.isWeek,
      isMonth: event.isMonth,
    ));
  }
}
