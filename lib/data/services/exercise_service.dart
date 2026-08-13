import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/exercise.dart';

class ExerciseService {
  ExerciseService._();
  static final ExerciseService instance = ExerciseService._();

  List<Exercise>? _cache;

  Future<List<Exercise>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/exercises/exercises.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = (json['exercises'] as List)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<Exercise?> getById(String id) async {
    final all = await loadAll();
    return all.where((e) => e.id == id).firstOrNull;
  }

  /// Sync lookup — returns null if cache not yet loaded.
  Exercise? getCachedById(String id) =>
      _cache?.where((e) => e.id == id).firstOrNull;

  Future<Map<String, Exercise>> buildIndex() async {
    final all = await loadAll();
    return {for (final e in all) e.id: e};
  }
}
