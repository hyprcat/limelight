part of 'route_guard_bloc.dart';

@immutable
abstract class RouteGuardState {}

class RouteGuardInitial extends RouteGuardState {}

class LoggedIn extends RouteGuardState {}

class NotLoggedIn extends RouteGuardState {}
