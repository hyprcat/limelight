// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge_section.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoungeSectionAdapter extends TypeAdapter<LoungeSection> {
  @override
  final int typeId = 5;

  @override
  LoungeSection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoungeSection(
      id: fields[0] as String?,
      relatedCategory: fields[1] as String?,
      sectionName: fields[2] as String?,
      sectionDescription: fields[3] as String?,
      minimumLevelRequired: fields[4] as int?,
      onlyOwnerCanPost: fields[5] as bool?,
      creationDate: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoungeSection obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.relatedCategory)
      ..writeByte(2)
      ..write(obj.sectionName)
      ..writeByte(3)
      ..write(obj.sectionDescription)
      ..writeByte(4)
      ..write(obj.minimumLevelRequired)
      ..writeByte(5)
      ..write(obj.onlyOwnerCanPost)
      ..writeByte(6)
      ..write(obj.creationDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoungeSectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
