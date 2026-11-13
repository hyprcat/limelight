part of 'leaderboard_bloc.dart';

@immutable
abstract class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}

class LoadingLeaderboards extends LeaderboardState {}

class LoadedLeaderboards extends LeaderboardState {
  final UserRepo repo;

  LoadedLeaderboards({required this.repo});
}

class LeaderboardsError extends LeaderboardState {}
