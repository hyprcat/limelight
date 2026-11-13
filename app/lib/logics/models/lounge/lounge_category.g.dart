// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoungeCategoryAdapter extends TypeAdapter<LoungeCategory> {
  @override
  final int typeId = 4;

  @override
  LoungeCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoungeCategory(
      id: fields[0] as String?,
      categoryName: fields[1] as String?,
      categoryDescription: fields[2] as String?,
      totalSections: fields[3] as int?,
      creationDate: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoungeCategory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryName)
      ..writeByte(2)
      ..write(obj.categoryDescription)
      ..writeByte(3)
      ..write(obj.totalSections)
      ..writeByte(4)
      ..write(obj.creationDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoungeCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
