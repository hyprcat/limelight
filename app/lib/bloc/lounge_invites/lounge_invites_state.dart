part of 'lounge_invites_bloc.dart';

@immutable
sealed class LoungeInvitesState {}

final class LoungeInvitesInitial extends LoungeInvitesState {}

class InviteFetchSuccess extends LoungeInvitesState {
  final UserRepo repo;
  InviteFetchSuccess(this.repo);
}

class InviteAccepted extends LoungeInvitesState {}

class InviteRejected extends LoungeInvitesState {}

class InvitationsLoading extends LoungeInvitesState {}

class InvitationError extends LoungeInvitesState {}

class InvitationErrorNotification extends LoungeInvitesState {}
