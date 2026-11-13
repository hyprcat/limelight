import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:meta/meta.dart';

import 'package:lime_time_app/logics/engines/lounge_engine.dart';
import 'package:lime_time_app/logics/repos/lounge_repo.dart';

part 'lounge_expanded_event.dart';
part 'lounge_expanded_state.dart';

class LoungeExpandedBloc
    extends Bloc<LoungeExpandedEvent, LoungeExpandedState> {
  PostRepo? repo = PostRepo();
  UserRepo? userRepo = UserRepo();
  LoungeExpandedBloc(this.repo, this.userRepo)
      : super(LoungeExpandedInitial()) {
    on<LoadMorePosts>((event, emit) async {
      try {
        repo = await LoungeEngine().loadExtraPosts(repo!, event.endpoint);
        emit(PostFetchedSuccess(repo!));
      } catch (e) {
        emit(PostFetchedSuccess(repo!));
      }
    });

    on<LoadMoreUsers>((event, emit) async {
      try {
        userRepo =
            await LoungeEngine().fetchMoreUsers(userRepo!, event.endpoint);
        emit(UsersFetchedSuccess(userRepo!));
      } catch (e) {
        emit(UsersFetchedSuccess(userRepo!));
      }
    });
  }
}
