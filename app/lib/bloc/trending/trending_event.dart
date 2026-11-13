part of 'trending_bloc.dart';

@immutable
abstract class TrendingEvent {}

class LoadTrendingVideos extends TrendingEvent {
  final Map data;
  final bool isDay;
  final bool isWeek;
  final bool isMonth;
  final bool isYear;
  final bool onlyShortVideos;

  LoadTrendingVideos(this.data, this.isDay, this.isWeek, this.isMonth,
      this.isYear, this.onlyShortVideos);
}
