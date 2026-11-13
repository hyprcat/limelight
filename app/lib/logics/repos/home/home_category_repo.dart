import 'package:lime_time_app/logics/models/banners/big_banner.dart';
import 'package:lime_time_app/logics/models/banners/small_banner_card.dart';
import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';
import 'package:lime_time_app/logics/models/videos/video_post.dart';
import 'package:lime_time_app/logics/repos/threads/video_comment_thread.dart';
import 'package:lime_time_app/logics/repos/threads/video_comment_thread_repo.dart';
import 'package:lime_time_app/logics/repos/lounge_repo.dart';
import 'package:lime_time_app/logics/repos/user_repo.dart';
import 'package:lime_time_app/logics/repos/video_repo.dart';

class HomeCategoryRepo {
  String? label;
  String? type;
  String? title;
  UserRepo? userData = UserRepo();
  VideoRepo? videoData = VideoRepo();
  PostRepo postRepo = PostRepo();
  ContestBanner banner = ContestBanner();
  SmallBanner smallBanner = SmallBanner();
  VideoCommentThreadRepo commentRepo = VideoCommentThreadRepo();

  HomeCategoryRepo.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    type = json['type'];
    title = json['title'];
    if (type == 'users' || type == 'user_type_2') {
      for (var i in json['data']) {
        userData!.profiles.add(UserProfile.fromJson(i));
      }
    } else if (type == 'lounge_threads' || type == 'lounge_threads_full') {
      for (var i in json['data']) {
        postRepo.posts.add(Post.fromJson(i));
      }
    } else if (type == 'video_threads') {
      for (var i in json['data']) {
        commentRepo.data.add(VideoCommentThread.fromJson(i));
      }
    } else if (type == 'full_size_banner') {
      banner = ContestBanner.fromJson(json);
    } else if (type == "half_size_banner") {
      smallBanner = SmallBanner.fromJson(json);
    } else {
      for (var i in json['data']) {
        videoData!.videos.add(VideoPost.fromJson(i));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['type'] = type;
    data['title'] = title;
    return data;
  }
}
