import 'package:bloc/bloc.dart';
import 'package:lime_time_app/logics/engines/lounge_engine.dart';
import 'package:lime_time_app/logics/engines/video_engine.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/comment_repo.dart';
import 'package:lime_time_app/logics/repos/lounge_repo.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';
import 'package:meta/meta.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  UserRepo userRepo = UserRepo();
  VideoRepo videoRepo = VideoRepo();
  VideoCommentRepo commentRepo = VideoCommentRepo(VideoPost());
  PostRepo postRepo = PostRepo();

  SearchBloc() : super(SearchInitial()) {
    on<LoadInitial>((event, emit) {
      emit(SearchInitial());
    });

    on<SearchVideos>((event, emit) async {
      try {
        videoRepo =
            await VideoEngine().fetchSearchVideos(videoRepo, event.query);
        emit(VideoSearchState(videoRepo));
      } catch (e) {
        emit(SearchError());
      }
    });

    on<SearchUsers>((event, emit) async {
      try {
        userRepo = await VideoEngine().fetchSearchUsers(userRepo, event.query);
        emit(UserSearchState(userRepo));
      } catch (e) {
        emit(SearchError());
      }
    });

    on<SearchComments>((event, emit) async {
      try {
        commentRepo =
            await VideoEngine().fetchSearchComments(commentRepo, event.query);
        emit(CommentSearchState(commentRepo));
      } catch (e) {
        emit(SearchError());
      }
    });

    on<SearchLoungePosts>((event, emit) async {
      try {
        postRepo =
            await LoungeEngine().loadSearchResults(postRepo, event.query);
        emit(LoungePostSearchState(postRepo));
      } catch (e) {
        emit(SearchError());
      }
    });
  }
}
