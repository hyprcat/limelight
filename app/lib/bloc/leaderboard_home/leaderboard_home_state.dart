part of 'leaderboard_home_bloc.dart';

@immutable
abstract class LeaderboardHomeState {}

class LeaderboardHomeInitial extends LeaderboardHomeState {}

class LeaderboardHomeSuccess extends LeaderboardHomeState {
  final String? city;
  final String? categoryId;
  final String? country;
  final String? region;
  final bool? isDay;
  final bool? isWeek;
  final bool? isMonth;

  LeaderboardHomeSuccess(
      {required this.city,
      required this.categoryId,
      required this.country,
      required this.region,
      required this.isDay,
      required this.isWeek,
      required this.isMonth});
}

class LeaderboardHomeLoading extends LeaderboardHomeState {}
