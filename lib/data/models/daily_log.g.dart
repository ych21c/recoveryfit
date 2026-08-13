// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'daily_log.dart';

// ── ExerciseLogEntry ─────────────────────────────────────────────────────────

class ExerciseLogEntryAdapter extends TypeAdapter<ExerciseLogEntry> {
  @override
  final int typeId = 5;

  @override
  ExerciseLogEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseLogEntry(
      exerciseId: fields[0] as String,
      status: fields[1] as String,
      painLevel: fields[2] as int?,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseLogEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.painLevel)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseLogEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// ── DailyLog ─────────────────────────────────────────────────────────────────

class DailyLogAdapter extends TypeAdapter<DailyLog> {
  @override
  final int typeId = 6;

  @override
  DailyLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLog(
      dateKey: fields[0] as String,
      planId: fields[1] as String,
      overallPainLevel: fields[2] as int,
      entries: (fields[3] as List).cast<ExerciseLogEntry>(),
      sessionCompleted: fields[4] as bool,
      sessionNote: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.planId)
      ..writeByte(2)
      ..write(obj.overallPainLevel)
      ..writeByte(3)
      ..write(obj.entries)
      ..writeByte(4)
      ..write(obj.sessionCompleted)
      ..writeByte(5)
      ..write(obj.sessionNote);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
