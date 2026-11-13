// ignore_for_file: prefer_collection_literals

class UserProfile {
  String? userName;
  String? userEmail;
  int? age;
  String? bio;
  String? gender;
  String? profilePicture;
  String? profileBanner;
  int? joinedCommunities;
  String? creationDate;
  bool? isCreator;
  bool? isAdvertisor;

  UserProfile(
      {this.userName,
      this.userEmail,
      this.age,
      this.bio,
      this.gender,
      this.profilePicture,
      this.profileBanner,
      this.joinedCommunities,
      this.creationDate,
      this.isCreator,
      this.isAdvertisor});

  UserProfile.fromJson(Map<String, dynamic> json) {
    userName = json['user_name'];
    userEmail = json['user_email'];
    age = json['age'];
    bio = json['bio'];
    gender = json['gender'];
    profilePicture = json['profile_picture'];
    profileBanner = json['profile_banner'];
    joinedCommunities = json['joined_communities'];
    creationDate = json['creation_date'];
    isCreator = json['is_creator'];
    isAdvertisor = json['is_advertisor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['user_name'] = userName;
    data['user_email'] = userEmail;
    data['age'] = age;
    data['bio'] = bio;
    data['gender'] = gender;
    data['profile_picture'] = profilePicture;
    data['profile_banner'] = profileBanner;
    data['joined_communities'] = joinedCommunities;
    data['creation_date'] = creationDate;
    data['is_creator'] = isCreator;
    data['is_advertisor'] = isAdvertisor;
    return data;
  }
}
