import 'package:lime_time_app/logics/repos/threads/video_comment_thread.dart';

class VideoCommentThreadRepo {
  int pageNumber = 1;
  int totalPages = 1;
  List<VideoCommentThread> data = [];

  VideoCommentThreadRepo();

  VideoCommentThreadRepo.fromJson(Map<String, dynamic> json) {
    pageNumber = json['page_number'];
    totalPages = json['total_pages'];
    if (json['data'] != null) {
      data = <VideoCommentThread>[];
      json['data'].forEach((v) {
        data.add(VideoCommentThread.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page_number'] = pageNumber;
    data['total_pages'] = totalPages;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }

  void merge() {}
}
