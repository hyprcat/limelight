// ignore_for_file: must_be_immutable

part of 'home_main_bloc.dart';

@immutable
abstract class HomeMainState {}

class HomeMainInitial extends HomeMainState {}

class HomeLoadingState extends HomeMainState {}

class HomeLoadSuccess extends HomeMainState {
  UserProfile loggedInUser;
  HomeLoadSuccess(this.loggedInUser);
}

class HomeError extends HomeMainState {}
