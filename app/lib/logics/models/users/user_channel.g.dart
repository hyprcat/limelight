// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_channel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserChannelAdapter extends TypeAdapter<UserChannel> {
  @override
  final int typeId = 2;

  @override
  UserChannel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserChannel(
      id: fields[0] as String?,
      name: fields[1] as String?,
      channelDescription: fields[2] as String?,
      subscriberCount: fields[3] as int?,
      videosCount: fields[4] as int?,
      level: fields[5] as int?,
      xP: fields[6] as int?,
      metricsLastUpdated: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserChannel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.channelDescription)
      ..writeByte(3)
      ..write(obj.subscriberCount)
      ..writeByte(4)
      ..write(obj.videosCount)
      ..writeByte(5)
      ..write(obj.level)
      ..writeByte(6)
      ..write(obj.xP)
      ..writeByte(7)
      ..write(obj.metricsLastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
