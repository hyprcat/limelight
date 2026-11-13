part of 'leaderboard_bloc.dart';

@immutable
abstract class LeaderboardEvent {}

class LoadLeaderboard extends LeaderboardEvent {
  final Map data;
  final bool isDay;
  final bool isWeek;
  final bool isMonth;

  LoadLeaderboard(
      {required this.isDay,
      required this.isWeek,
      required this.isMonth,
      required this.data});
}
