part of 'lounge_home_bloc.dart';

@immutable
abstract class LoungeHomeEvent {}

class LoadLoungeHome extends LoungeHomeEvent {}

class LoadTopPosts extends LoungeHomeEvent {}

class LoadTopLounges extends LoungeHomeEvent {}
