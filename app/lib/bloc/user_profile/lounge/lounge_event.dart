part of 'lounge_bloc.dart';

@immutable
abstract class LoungeEvent {}

class LoadLounge extends LoungeEvent {
  final bool refresh;
  final UserProfile user;

  LoadLounge(this.refresh, this.user);
}

class RemoveCategory extends LoungeEvent {}

class RemoveSection extends LoungeEvent {}
