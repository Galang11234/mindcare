import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const _keyUser = 'user_profile';
  static const _keyMoods = 'mood_entries';
  static const _keyJournals = 'journal_entries';
  static const _keyDass = 'dass_results';
  static const _keyOnboarded = 'is_onboarded';
  static const _keyLoggedIn = 'is_logged_in';

  // ─── Auth ───────────────────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarded) ?? false;
  }

  static Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarded, true);
  }

  static Future<void> setLoggedIn(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, val);
  }

  // ─── User Profile ───────────────────────────────────────────────────────────
  static Future<void> saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static Future<UserProfile?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyUser);
    if (str == null) return null;
    return UserProfile.fromJson(jsonDecode(str));
  }

  // ─── Mood Entries ───────────────────────────────────────────────────────────
  static Future<void> saveMoodEntry(MoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getMoodEntries();
    list.insert(0, entry);
    await prefs.setString(
      _keyMoods,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<MoodEntry>> getMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyMoods);
    if (str == null) return [];
    final list = jsonDecode(str) as List;
    return list.map((e) => MoodEntry.fromJson(e)).toList();
  }

  // ─── Journal Entries ─────────────────────────────────────────────────────────
  static Future<void> saveJournalEntry(JournalEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getJournalEntries();
    final idx = list.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      list[idx] = entry;
    } else {
      list.insert(0, entry);
    }
    await prefs.setString(
      _keyJournals,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> deleteJournalEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getJournalEntries();
    list.removeWhere((e) => e.id == id);
    await prefs.setString(
      _keyJournals,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<JournalEntry>> getJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyJournals);
    if (str == null) return [];
    final list = jsonDecode(str) as List;
    return list.map((e) => JournalEntry.fromJson(e)).toList();
  }

  // ─── DASS Results ────────────────────────────────────────────────────────────
  static Future<void> saveDassResult(Dass21Result result) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getDassResults();
    list.insert(0, result);
    await prefs.setString(
      _keyDass,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<Dass21Result>> getDassResults() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyDass);
    if (str == null) return [];
    final list = jsonDecode(str) as List;
    return list.map((e) => Dass21Result.fromJson(e)).toList();
  }

  // ─── Clear All ───────────────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}