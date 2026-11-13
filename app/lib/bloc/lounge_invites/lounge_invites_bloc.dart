import 'package:bloc/bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/logics/engines/lounge_engine.dart';
import 'package:lime_time_app/logics/models/lounge/lounge.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:meta/meta.dart';

part 'lounge_invites_event.dart';
part 'lounge_invites_state.dart';

class LoungeInvitesBloc extends Bloc<LoungeInvitesEvent, LoungeInvitesState> {
  UserRepo userRepo = UserRepo();
  LoungeInvitesBloc() : super(LoungeInvitesInitial()) {
    on<FetchAllInvites>((event, emit) async {
      try {
        userRepo = await LoungeEngine().fetchLoungeInvitations(userRepo);
        emit(InviteFetchSuccess(userRepo));
      } catch (e) {
        emit(InvitationError());
      }
    });

    on<AcceptInvite>((event, emit) async {
      try {
        var result = await LoungeEngine().acceptLoungeInvitation(
            {'lounge_id': event.lounge.id, 'token': sessionData!['token']});
        if (result) {
          emit(InviteAccepted());
        } else {
          emit(InvitationErrorNotification());
        }
      } catch (e) {
        emit(InvitationError());
      }
    });

    on<RejectInvite>((event, emit) async {
      try {
        var result = await LoungeEngine().denyLoungeInvitation(
            {'lounge_id': event.lounge.id, 'token': sessionData!['token']});
        if (result) {
          emit(InviteRejected());
        } else {
          emit(InvitationErrorNotification());
        }
      } catch (e) {
        emit(InvitationError());
      }
    });

    on<SearchInvites>((event, emit) async {
      try {} catch (e) {
        emit(InvitationError());
      }
    });
  }
}
