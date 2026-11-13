part of 'lounge_invites_bloc.dart';

@immutable
sealed class LoungeInvitesEvent {}

class FetchAllInvites extends LoungeInvitesEvent {}

class AcceptInvite extends LoungeInvitesEvent {
  final UserLounge lounge;

  AcceptInvite(this.lounge);
}

class RejectInvite extends LoungeInvitesEvent {
  final UserLounge lounge;

  RejectInvite(this.lounge);
}

class SearchInvites extends LoungeInvitesEvent {}
