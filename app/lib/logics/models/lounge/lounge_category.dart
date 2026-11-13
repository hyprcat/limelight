import 'package:hive/hive.dart';

part 'lounge_category.g.dart';

@HiveType(typeId: 4)
class LoungeCategory {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? categoryName;
  @HiveField(2)
  String? categoryDescription;
  @HiveField(3)
  int? totalSections;
  @HiveField(4)
  String? creationDate;

  LoungeCategory(
      {this.id,
      this.categoryName,
      this.categoryDescription,
      this.totalSections,
      this.creationDate});

  LoungeCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['category_name'];
    categoryDescription = json['category_description'];
    totalSections = json['total_sections'];
    creationDate = json['creation_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_name'] = categoryName;
    data['category_description'] = categoryDescription;
    data['total_sections'] = totalSections;
    data['creation_date'] = creationDate;
    return data;
  }
}
