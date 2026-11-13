// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/lounge_engine.dart';
import 'package:lime_time_app/logics/models/lounge/lounge_section.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/logics/repos/lounge_repo.dart';
import 'package:meta/meta.dart';

part 'lounge_section_event.dart';
part 'lounge_section_state.dart';

class LoungeSectionBloc extends Bloc<LoungeSectionEvent, LoungeSectionState> {
  PostRepo repo = PostRepo();
  LoungeSectionBloc(this.repo) : super(LoungeSectionInitial()) {
    on<LoadSectionPosts>((event, emit) async {
      try {
        emit(PostsLoading());
        if (event.endPoint == "fetch_child_posts" ||
            event.endPoint == "fetch_total_posts") {
          repo = await LoungeEngine().loadLoungePostsLEGACY(
              event.section.id!, repo, event.endPoint, event.post!);
        } else {
          repo = await LoungeEngine().loadLoungePostsLEGACY(
              event.section.id!, repo, event.endPoint, Post());
        }

        emit(PostLoadSuccess(repo));
      } catch (e) {
        rethrow;
      }
    });

    on<LoadThreadedPosts>((event, emit) async {
      try {
        emit(PostsLoading());
        repo = await LoungeEngine().loadThreadedComments(repo);
        emit(PostLoadSuccess(repo));
      } catch (e) {
        rethrow;
      }
    });

    on<AddLoungePost>((event, emit) async {
      try {
        var status = await LoungeEngine().createPost(event.data);

        if (status == "Post Created successfully." ||
            status ==
                "Post created. Now you are now a member of this lounge.") {
          emit(PostAdded(status));
        } else {
          emit(PostAddingError(error: status));
        }
      } catch (e) {
        emit(PostAddingError(error: e.toString()));
      }
    });

    on<RemoveLoungePost>((event, emit) async {
      try {
        var data = {
          'post_id': event.postId,
        };
        var response = await LoungeEngine().deletePost(data);
        if (response == 'success') {
          emit(PostDeletionSuccess());
          if (event.isRootPost) {
            emit(RefreshRootPosts());
          } else {
            emit(RefreshFollowUp());
          }
        } else {
          emit(PostDeletionSuccess());
        }
      } catch (E) {
        PostLoadError();
      }
    });
  }
}
