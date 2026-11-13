part of 'leaderboard_home_bloc.dart';

@immutable
abstract class LeaderboardHomeEvent {}

class LoadLeaderboardHome extends LeaderboardHomeEvent {
  final String? city;
  final String? categoryId;
  final String? country;
  final String? region;
  final bool? isDay;
  final bool? isWeek;
  final bool? isMonth;

  LoadLeaderboardHome({
    required this.city,
    required this.categoryId,
    required this.country,
    required this.region,
    required this.isDay,
    required this.isWeek,
    required this.isMonth,
  });
}
