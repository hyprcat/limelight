import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'trending_home_event.dart';
part 'trending_home_state.dart';

class TrendingHomeBloc extends Bloc<TrendingHomeEvent, TrendingHomeState> {
  TrendingHomeBloc() : super(TrendingHomeInitial()) {
    on<LoadMainTrendingHome>(load);
  }

  FutureOr<void> load(
      LoadMainTrendingHome event, Emitter<TrendingHomeState> emit) async {
    emit(TrendingHomeInitial());
    await Future.delayed(const Duration(milliseconds: 50));
    emit(FinalTrendingState(
        city: event.city,
        country: event.country,
        categoryId: event.categoryId,
        region: event.region,
        isDay: event.isDay,
        isWeek: event.isWeek,
        isMonth: event.isMonth,
        isYear: event.isYear,
        onlyShortVideos: event.onlyShorts));
  }
}
