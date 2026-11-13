// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      userId: fields[0] as int?,
      userName: fields[1] as String?,
      userEmail: fields[2] as String?,
      age: fields[3] as int?,
      bio: fields[4] as String?,
      gender: fields[5] as String?,
      profilePicture: fields[6] as String?,
      profileBanner: fields[7] as String?,
      joinedCommunities: fields[8] as int?,
      creationDate: fields[9] as String?,
      isCreator: fields[10] as bool?,
      isAdvertisor: fields[11] as bool?,
      userChannel: fields[12] as UserChannel?,
      userLounge: fields[13] as UserLounge?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.userEmail)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.bio)
      ..writeByte(5)
      ..write(obj.gender)
      ..writeByte(6)
      ..write(obj.profilePicture)
      ..writeByte(7)
      ..write(obj.profileBanner)
      ..writeByte(8)
      ..write(obj.joinedCommunities)
      ..writeByte(9)
      ..write(obj.creationDate)
      ..writeByte(10)
      ..write(obj.isCreator)
      ..writeByte(11)
      ..write(obj.isAdvertisor)
      ..writeByte(12)
      ..write(obj.userChannel)
      ..writeByte(13)
      ..write(obj.userLounge);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
