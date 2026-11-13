import 'package:lime_time_app/logics/repos/home/home_category_repo.dart';

class ExperimentalHomeRepo {
  List<HomeCategoryRepo>? homeSections;

  ExperimentalHomeRepo.fromJson(Map<String, dynamic> json) {
    if (json['message'] != null) {
      homeSections = <HomeCategoryRepo>[];
      json['message'].forEach((v) {
        homeSections!.add(HomeCategoryRepo.fromJson(v));
      });
    }
  }
}
