import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/user_engine.dart';
import 'package:meta/meta.dart';

import 'package:lime_time_app/logics/models/contests/september_contest.dart';

part 'september_event.dart';
part 'september_state.dart';

class SeptemberBloc extends Bloc<SeptemberEvent, SeptemberState> {
  SeptemberBloc() : super(SeptemberInitial()) {
    on<LoadContestData>((event, emit) async {
      try {
        emit(LoadingSeptemberState());
        SeptemberContestData contestData =
            await UserEngine().getSeptemberContestDetails();
        emit(SeptemberContestLoadSuccessful(contestData));
      } catch (e) {
        rethrow;
      }
    });
  }
}
