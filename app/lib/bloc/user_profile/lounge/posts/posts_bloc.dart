import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:lime_time_app/defaults/constants.dart';
import 'package:lime_time_app/logics/engines/lounge_engine.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:meta/meta.dart';

part 'posts_event.dart';
part 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  Post post;

  PostsBloc(this.post) : super(PostsInitial()) {
    on<LoadPost>(loadPost);
    on<LikePost>(likePost);
    on<DislikePost>(dislikePost);
    on<RemoveLike>(removeLike);
    on<RemoveDislike>(removeDislike);
  }

  FutureOr<void> loadPost(LoadPost event, Emitter<PostsState> emit) {
    LoungeEngine().setPostImpressions(
        {'post_id': post.id, 'token': sessionData!['token']});
    emit(PostLoadSuccess(post.interactionStatus!));
  }

  FutureOr<void> likePost(LikePost event, Emitter<PostsState> emit) async {
    try {
      Map<String, dynamic> original = Map.from(event.post.interactionStatus!);
      Map<String, dynamic> map = Map.from(event.post.interactionStatus!);

      map['like'] = true;
      map['dislike'] = false;
      map['total_likes'] += 1;
      if (original['dislike'] == true) {
        map['total_dislikes'] -= 1;
      }
      emit(PostLoadSuccess(map));
      var response = await LoungeEngine().likePost(event.post);
      if (response == 'success' ||
          response == "You are a member of this lounge now.") {
        var reactionMap = await LoungeEngine().fetchPostReaction(event.post);
        if (response == "You are a member of this lounge now.") {
          emit(PostMessageDeliver(response));
        }

        emit(PostLoadSuccess(reactionMap));
      } else {
        emit(PostError(error: response));
        emit(PostLoadSuccess(post.interactionStatus!));
      }
    } catch (e) {
      emit(PostError(error: e.toString()));
      emit(PostLoadSuccess(post.interactionStatus!));
    }
  }

  FutureOr<void> dislikePost(
      DislikePost event, Emitter<PostsState> emit) async {
    try {
      Map<String, dynamic> original = Map.from(event.post.interactionStatus!);
      Map<String, dynamic> map = Map.from(event.post.interactionStatus!);

      map['like'] = false;
      map['dislike'] = true;
      map['total_dislikes'] += 1;

      if (original['like'] == true) {
        map['total_likes'] -= 1;
      }
      emit(PostLoadSuccess(map));
      var response = await LoungeEngine().dislikePost(event.post);
      if (response == 'success' ||
          response == "You are a member of this lounge now.") {
        var reactionMap = await LoungeEngine().fetchPostReaction(event.post);
        if (response == "You are a member of this lounge now.") {
          emit(PostMessageDeliver(response));
        }
        emit(PostLoadSuccess(reactionMap));
      } else {
        emit(PostError(error: response));
        emit(PostLoadSuccess(post.interactionStatus!));
      }
    } catch (e) {
      emit(PostError(error: e.toString()));
      emit(PostLoadSuccess(post.interactionStatus!));
    }
  }

  FutureOr<void> removeLike(RemoveLike event, Emitter<PostsState> emit) async {
    try {
      Map<String, dynamic> map = Map.from(event.post.interactionStatus!);

      map['dislike'] = false;
      map['like'] = false;
      map['total_likes'] -= 1;
      emit(PostLoadSuccess(map));
      var response = await LoungeEngine().removeLikePost(event.post);
      if (response == 'success') {
        var reactionMap = await LoungeEngine().fetchPostReaction(event.post);
        emit(PostLoadSuccess(reactionMap));
      } else {
        emit(PostError(error: response));
        emit(PostLoadSuccess(post.interactionStatus!));
      }
    } catch (e) {
      emit(PostError(error: e.toString()));
      emit(PostLoadSuccess(post.interactionStatus!));
    }
  }

  FutureOr<void> removeDislike(
      RemoveDislike event, Emitter<PostsState> emit) async {
    try {
      Map<String, dynamic> map = Map.from(event.post.interactionStatus!);

      map['dislike'] = false;
      map['like'] = false;
      map['total_likes'] -= 1;
      emit(PostLoadSuccess(map));
      var response = await LoungeEngine().removeDislikePost(event.post);
      if (response == 'success') {
        var reactionMap = await LoungeEngine().fetchPostReaction(event.post);
        emit(PostLoadSuccess(reactionMap));
      } else {
        emit(PostError(error: response));
        emit(PostLoadSuccess(post.interactionStatus!));
      }
    } catch (e) {
      emit(PostError(error: e.toString()));
      emit(PostLoadSuccess(post.interactionStatus!));
    }
  }
}
