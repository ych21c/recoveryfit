import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../models/workout_plan.dart';
import '../models/daily_log.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  late final SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  SharedPreferences get prefs {
    assert(_initialized, 'StorageService.init() must be called first');
    return _prefs;
  }

  // ── UserProfile ──────────────────────────────────────────────────────────

  Box<UserProfile> get _profileBox => Hive.box<UserProfile>('user_profile');

  UserProfile? get currentProfile =>
      _profileBox.isNotEmpty ? _profileBox.getAt(0) : null;

  Future<void> saveProfile(UserProfile profile) async {
    await _profileBox.clear();
    await _profileBox.add(profile);
  }

  // ── WorkoutPlan ──────────────────────────────────────────────────────────

  Box<WorkoutPlan> get _planBox => Hive.box<WorkoutPlan>('workout_plans');

  WorkoutPlan? get activePlan =>
      _planBox.values.where((p) => p.isActive).firstOrNull;

  Future<void> savePlan(WorkoutPlan plan) async {
    // Deactivate existing plans
    for (final p in _planBox.values) {
      p.isActive = false;
      await p.save();
    }
    await _planBox.add(plan);
  }

  List<WorkoutPlan> get allPlans => _planBox.values.toList();

  // ── DailyLog ─────────────────────────────────────────────────────────────

  Box<DailyLog> get _logBox => Hive.box<DailyLog>('daily_logs');

  DailyLog? getLog(String dateKey) =>
      _logBox.values.where((l) => l.dateKey == dateKey).firstOrNull;

  Future<void> saveLog(DailyLog log) async {
    final existing = _logBox.values
        .toList()
        .asMap()
        .entries
        .where((e) => e.value.dateKey == log.dateKey)
        .firstOrNull;
    if (existing != null) {
      await _logBox.putAt(existing.key, log);
    } else {
      await _logBox.add(log);
    }
  }

  List<DailyLog> getLogsInRange(DateTime start, DateTime end) {
    return _logBox.values.where((log) {
      final d = DateTime.tryParse(log.dateKey);
      if (d == null) return false;
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList()
      ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
  }

  // ── Settings (SharedPreferences) ─────────────────────────────────────────

  bool get onboardingDone =>
      _prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
  Future<void> setOnboardingDone() =>
      _prefs.setBool(AppConstants.keyOnboardingDone, true);

  String? get apiKey => _prefs.getString(AppConstants.keyApiKey);
  Future<void> saveApiKey(String key) =>
      _prefs.setString(AppConstants.keyApiKey, key);

  int get llmCallsThisMonth =>
      _prefs.getInt(AppConstants.keyLlmCallsThisMonth) ?? 0;

  Future<void> incrementLlmCalls() async {
    final resetDateStr = _prefs.getString(AppConstants.keyLlmCallsResetDate);
    final now = DateTime.now();
    final resetDate = resetDateStr != null
        ? DateTime.tryParse(resetDateStr)
        : null;

    // Reset counter if we've crossed a month boundary
    if (resetDate == null ||
        now.year != resetDate.year ||
        now.month != resetDate.month) {
      await _prefs.setInt(AppConstants.keyLlmCallsThisMonth, 1);
      await _prefs.setString(
          AppConstants.keyLlmCallsResetDate, now.toIso8601String());
    } else {
      await _prefs.setInt(
          AppConstants.keyLlmCallsThisMonth, llmCallsThisMonth + 1);
    }
  }

  bool get canMakeLlmCall =>
      llmCallsThisMonth < AppConstants.maxMonthlyLlmCalls;

  bool get subscriptionActive =>
      _prefs.getBool(AppConstants.keySubscriptionActive) ?? false;
  Future<void> setSubscriptionActive(bool active) =>
      _prefs.setBool(AppConstants.keySubscriptionActive, active);

  DateTime? get subscriptionExpiry {
    final s = _prefs.getString(AppConstants.keySubscriptionExpiry);
    return s != null ? DateTime.tryParse(s) : null;
  }

  Future<void> setSubscriptionExpiry(DateTime expiry) =>
      _prefs.setString(
          AppConstants.keySubscriptionExpiry, expiry.toIso8601String());

  DateTime? get lastWeeklyAdjust {
    final s = _prefs.getString(AppConstants.keyLastWeeklyAdjust);
    return s != null ? DateTime.tryParse(s) : null;
  }

  Future<void> setLastWeeklyAdjust(DateTime date) =>
      _prefs.setString(
          AppConstants.keyLastWeeklyAdjust, date.toIso8601String());

  bool get canAdjustWeekly {
    final last = lastWeeklyAdjust;
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= 7;
  }
}
