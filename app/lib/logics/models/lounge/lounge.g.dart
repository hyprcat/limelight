// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserLoungeAdapter extends TypeAdapter<UserLounge> {
  @override
  final int typeId = 3;

  @override
  UserLounge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserLounge(
      id: fields[0] as String?,
      totalMembers: fields[1] as int?,
      totalCategories: fields[2] as int?,
      loungeDescription: fields[3] as String?,
      loungeTiers: fields[4] as int?,
      name: fields[5] as String?,
      categories: (fields[6] as List?)?.cast<LoungeCategory>(),
      sections: (fields[7] as List?)?.cast<LoungeSection>(),
      xP: fields[8] as int?,
      level: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserLounge obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.totalMembers)
      ..writeByte(2)
      ..write(obj.totalCategories)
      ..writeByte(3)
      ..write(obj.loungeDescription)
      ..writeByte(4)
      ..write(obj.loungeTiers)
      ..writeByte(5)
      ..write(obj.name)
      ..writeByte(6)
      ..write(obj.categories)
      ..writeByte(7)
      ..write(obj.sections)
      ..writeByte(8)
      ..write(obj.xP)
      ..writeByte(9)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLoungeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
