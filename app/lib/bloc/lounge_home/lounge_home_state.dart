// ignore_for_file: must_be_immutable

part of 'lounge_home_bloc.dart';

@immutable
abstract class LoungeHomeState {}

class LoungeHomeInitial extends LoungeHomeState {}

class LoadingLoungeHome extends LoungeHomeState {}

class LoungeHomeSuccess extends LoungeHomeState {
  LoungeHome home;
  LoungeHomeSuccess(this.home);
}
