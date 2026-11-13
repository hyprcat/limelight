import 'package:lime_time_app/logics/models/lounge/post.dart';
import 'package:lime_time_app/logics/models/users/user_profile.dart';

class LoungeHome {
  List<UserProfile>? topLounges;
  List<Post>? topLoungePosts;
  List<UserProfile>? topLoungesUserJoined;
  List<Post>? topLoungePostsUserJoined;

  LoungeHome(
      {this.topLounges,
      this.topLoungePosts,
      this.topLoungesUserJoined,
      this.topLoungePostsUserJoined});

  LoungeHome.fromJson(Map<String, dynamic> json) {
    if (json['top_lounges'] != null) {
      topLounges = <UserProfile>[];
      json['top_lounges'].forEach((v) {
        topLounges!.add(UserProfile.fromJson(v));
      });
    }
    if (json['top_lounge_posts'] != null) {
      topLoungePosts = <Post>[];
      json['top_lounge_posts'].forEach((v) {
        topLoungePosts!.add(Post.fromJson(v));
      });
    }
    if (json['top_lounges_user_joined'] != null) {
      topLoungesUserJoined = <UserProfile>[];
      json['top_lounges_user_joined'].forEach((v) {
        topLoungesUserJoined!.add(UserProfile.fromJson(v));
      });
    }
    if (json['top_lounge_posts_user_joined'] != null) {
      topLoungePostsUserJoined = <Post>[];
      json['top_lounge_posts_user_joined'].forEach((v) {
        topLoungePostsUserJoined!.add(Post.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (topLounges != null) {
      data['top_lounges'] = topLounges!.map((v) => v.toJson()).toList();
    }
    if (topLoungePosts != null) {
      data['top_lounge_posts'] =
          topLoungePosts!.map((v) => v.toJson()).toList();
    }
    if (topLoungesUserJoined != null) {
      data['top_lounges_user_joined'] =
          topLoungesUserJoined!.map((v) => v.toJson()).toList();
    }
    if (topLoungePostsUserJoined != null) {
      data['top_lounge_posts_user_joined'] =
          topLoungePostsUserJoined!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
