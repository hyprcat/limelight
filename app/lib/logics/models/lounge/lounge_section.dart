import 'package:hive/hive.dart';

part 'lounge_section.g.dart';

@HiveType(typeId: 5)
class LoungeSection {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? relatedCategory;
  @HiveField(2)
  String? sectionName;
  @HiveField(3)
  String? sectionDescription;
  @HiveField(4)
  int? minimumLevelRequired;
  @HiveField(5)
  bool? onlyOwnerCanPost;
  @HiveField(6)
  String? creationDate;

  LoungeSection(
      {this.id,
      this.relatedCategory,
      this.sectionName,
      this.sectionDescription,
      this.minimumLevelRequired,
      this.onlyOwnerCanPost,
      this.creationDate});

  LoungeSection.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    relatedCategory = json['related_category'];
    sectionName = json['section_name'];
    sectionDescription = json['section_description'];
    minimumLevelRequired = json['minimum_level_required'];
    onlyOwnerCanPost = json['only_owner_can_post'];
    creationDate = json['creation_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['related_category'] = relatedCategory;
    data['section_name'] = sectionName;
    data['section_description'] = sectionDescription;
    data['minimum_level_required'] = minimumLevelRequired;
    data['only_owner_can_post'] = onlyOwnerCanPost;
    data['creation_date'] = creationDate;
    return data;
  }
}
