part of 'trending_home_bloc.dart';

@immutable
abstract class TrendingHomeEvent {}

class LoadMainTrendingHome extends TrendingHomeEvent {
  final String? city;
  final String? categoryId;
  final String? country;
  final String? region;
  final bool? isDay;
  final bool? isWeek;
  final bool? isMonth;
  final bool? isYear;
  final bool? onlyShorts;

  LoadMainTrendingHome(
      {required this.city,
      required this.categoryId,
      required this.country,
      required this.region,
      required this.isDay,
      required this.isWeek,
      required this.isMonth,
      required this.isYear,
      required this.onlyShorts});
}
