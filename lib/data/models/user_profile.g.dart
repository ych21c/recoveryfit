// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'user_profile.dart';

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String,
      injuryDescription: fields[1] as String,
      painLevel: fields[2] as int,
      goal: fields[3] as String,
      weeklyFrequency: fields[4] as int,
      environment: fields[5] as String,
      equipment: (fields[6] as List).cast<String>(),
      createdAt: fields[7] as DateTime,
      detectedBodyParts: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.injuryDescription)
      ..writeByte(2)
      ..write(obj.painLevel)
      ..writeByte(3)
      ..write(obj.goal)
      ..writeByte(4)
      ..write(obj.weeklyFrequency)
      ..writeByte(5)
      ..write(obj.environment)
      ..writeByte(6)
      ..write(obj.equipment)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.detectedBodyParts);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
