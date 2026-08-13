// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'workout_plan.dart';

// ── PlannedExercise ──────────────────────────────────────────────────────────

class PlannedExerciseAdapter extends TypeAdapter<PlannedExercise> {
  @override
  final int typeId = 1;

  @override
  PlannedExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlannedExercise(
      exerciseId: fields[0] as String,
      phase: fields[1] as String,
      sets: fields[2] as int,
      reps: fields[3] as String,
      restSeconds: fields[4] as int,
      intensityNote: fields[5] as String,
      coachNote: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PlannedExercise obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.phase)
      ..writeByte(2)
      ..write(obj.sets)
      ..writeByte(3)
      ..write(obj.reps)
      ..writeByte(4)
      ..write(obj.restSeconds)
      ..writeByte(5)
      ..write(obj.intensityNote)
      ..writeByte(6)
      ..write(obj.coachNote);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// ── WorkoutDay ───────────────────────────────────────────────────────────────

class WorkoutDayAdapter extends TypeAdapter<WorkoutDay> {
  @override
  final int typeId = 2;

  @override
  WorkoutDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutDay(
      dayOfWeek: fields[0] as int,
      focusArea: fields[1] as String,
      estimatedMinutes: fields[2] as int,
      exercises: (fields[3] as List).cast<PlannedExercise>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutDay obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.dayOfWeek)
      ..writeByte(1)
      ..write(obj.focusArea)
      ..writeByte(2)
      ..write(obj.estimatedMinutes)
      ..writeByte(3)
      ..write(obj.exercises);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// ── WorkoutWeek ──────────────────────────────────────────────────────────────

class WorkoutWeekAdapter extends TypeAdapter<WorkoutWeek> {
  @override
  final int typeId = 3;

  @override
  WorkoutWeek read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutWeek(
      weekNumber: fields[0] as int,
      theme: fields[1] as String,
      days: (fields[2] as List).cast<WorkoutDay>(),
      progressionNote: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutWeek obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.weekNumber)
      ..writeByte(1)
      ..write(obj.theme)
      ..writeByte(2)
      ..write(obj.days)
      ..writeByte(3)
      ..write(obj.progressionNote);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutWeekAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// ── WorkoutPlan ──────────────────────────────────────────────────────────────

class WorkoutPlanAdapter extends TypeAdapter<WorkoutPlan> {
  @override
  final int typeId = 4;

  @override
  WorkoutPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutPlan(
      id: fields[0] as String,
      userProfileId: fields[1] as String,
      createdAt: fields[2] as DateTime,
      weeks: (fields[3] as List).cast<WorkoutWeek>(),
      safetyDisclaimer: fields[4] as String,
      isActive: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutPlan obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userProfileId)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.weeks)
      ..writeByte(4)
      ..write(obj.safetyDisclaimer)
      ..writeByte(5)
      ..write(obj.isActive);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
