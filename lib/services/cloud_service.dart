import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';


// Semua data user tersimpan di Supabase (cloud sync multi-device)
class CloudService {
  static final _sb = Supabase.instance.client;

  // ── MOOD ────────────────────────────────────────────────────
  static Future<bool> saveMood({
    required int moodLevel,
    required String moodLabel,
    required String emoji,
    required List<String> emotions,
    String? note,
    DateTime? date,
  }) async {
    final uid = AuthService.userId;
    if (uid == null) return false;
    try {
      await _sb.from('mood_entries').insert({
        'user_id': uid,
        'mood_level': moodLevel,
        'mood_label': moodLabel,
        'emoji': emoji,
        'emotions': emotions,
        'note': note,
        'recorded_at': (date ?? DateTime.now()).toIso8601String(),
      });
      return true;
    } catch (_) { return false; }
  }

  static Future<List<Map<String, dynamic>>> getMoods({int limit = 90}) async {
    final uid = AuthService.userId;
    if (uid == null) return [];
    try {
      final data = await _sb
          .from('mood_entries').select()
          .eq('user_id', uid)
          .order('recorded_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) { return []; }
  }

  static Future<bool> deleteMood(String id) async {
    try {
      await _sb.from('mood_entries').delete().eq('id', id);
      return true;
    } catch (_) { return false; }
  }

  // ── JOURNAL ─────────────────────────────────────────────────
  static Future<String?> saveJournal({
    String? id,
    required String title,
    required String content,
    required String mood,
    required List<String> tags,
    DateTime? date,
  }) async {
    final uid = AuthService.userId;
    if (uid == null) return null;
    try {
      if (id != null) {
        // Update
        await _sb.from('journal_entries').update({
          'title': title, 'content': content,
          'mood': mood, 'tags': tags,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', id).eq('user_id', uid);
        return id;
      } else {
        // Insert
        final res = await _sb.from('journal_entries').insert({
          'user_id': uid, 'title': title, 'content': content,
          'mood': mood, 'tags': tags,
          'recorded_at': (date ?? DateTime.now()).toIso8601String(),
        }).select('id').single();
        return res['id'] as String;
      }
    } catch (_) { return null; }
  }

  static Future<List<Map<String, dynamic>>> getJournals({int limit = 100}) async {
    final uid = AuthService.userId;
    if (uid == null) return [];
    try {
      final data = await _sb
          .from('journal_entries').select()
          .eq('user_id', uid)
          .order('recorded_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) { return []; }
  }

  static Future<bool> deleteJournal(String id) async {
    final uid = AuthService.userId;
    if (uid == null) return false;
    try {
      await _sb.from('journal_entries').delete()
          .eq('id', id).eq('user_id', uid);
      return true;
    } catch (_) { return false; }
  }

  // ── DASS ────────────────────────────────────────────────────
  static Future<bool> saveDass({
    required int depressionScore,
    required int anxietyScore,
    required int stressScore,
    required String depressionLevel,
    required String anxietyLevel,
    required String stressLevel,
    required List<int> answers,
  }) async {
    final uid = AuthService.userId;
    if (uid == null) return false;
    try {
      await _sb.from('dass_results').insert({
        'user_id': uid,
        'depression_score': depressionScore,
        'anxiety_score': anxietyScore,
        'stress_score': stressScore,
        'depression_level': depressionLevel,
        'anxiety_level': anxietyLevel,
        'stress_level': stressLevel,
        'answers': answers,
        'recorded_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) { return false; }
  }

  static Future<List<Map<String, dynamic>>> getDassResults({int limit = 20}) async {
    final uid = AuthService.userId;
    if (uid == null) return [];
    try {
      final data = await _sb
          .from('dass_results').select()
          .eq('user_id', uid)
          .order('recorded_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) { return []; }
  }

  // ── CHAT HISTORY ────────────────────────────────────────────
  static Future<void> saveChatMessage({
    required String sessionId,
    required String role,
    required String content,
  }) async {
    final uid = AuthService.userId;
    if (uid == null) return;
    try {
      await _sb.from('chat_messages').insert({
        'user_id': uid, 'session_id': sessionId,
        'role': role, 'content': content,
      });
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getChatHistory({
    required String sessionId,
    int limit = 50,
  }) async {
    final uid = AuthService.userId;
    if (uid == null) return [];
    try {
      final data = await _sb
          .from('chat_messages').select()
          .eq('user_id', uid).eq('session_id', sessionId)
          .order('created_at').limit(limit);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) { return []; }
  }

  // ── NOTIFICATIONS ────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final uid = AuthService.userId;
    if (uid == null) return [];
    try {
      final data = await _sb
          .from('notifications').select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(30);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) { return []; }
  }

  static Future<void> markNotifRead(String id) async {
    try {
      await _sb.from('notifications').update({'is_read': true}).eq('id', id);
    } catch (_) {}
  }

  static Future<int> getUnreadNotifCount() async {
    // Hindari fitur count/FetchOptions yang berbeda-beda antar versi supabase_flutter.
    // Cara paling aman: ambil data unread yang terbatas lalu hitung jumlahnya.
    final uid = AuthService.userId;
    if (uid == null) return 0;

    try {
      final data = await _sb
          .from('notifications')
          .select('id')
          .eq('user_id', uid)
          .eq('is_read', false)
          .limit(1000);

      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }


  // ── STATS (for dashboard) ────────────────────────────────────
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final uid = AuthService.userId;
    if (uid == null) return {};
    try {
      final moods = await getMoods(limit: 30);
      final journals = await getJournals(limit: 100);
      final dass = await getDassResults(limit: 10);
      final notifs = await getUnreadNotifCount();

      // Streak calculation
      int streak = 0;
      final now = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final day = DateTime(now.year, now.month, now.day - i);
        final hasEntry = moods.any((m) {
          final d = DateTime.tryParse(m['recorded_at'] ?? '');
          return d != null && d.year == day.year && d.month == day.month && d.day == day.day;
        });
        if (hasEntry) streak++;
        else if (i > 0) break;
      }

      double avgMood = 0;
      if (moods.isNotEmpty) {
        final recent = moods.take(7).toList();
        avgMood = recent.map((m) => (m['mood_level'] as int? ?? 0)).reduce((a, b) => a + b) / recent.length;
      }

      return {
        'moodCount': moods.length,
        'journalCount': journals.length,
        'dassCount': dass.length,
        'streak': streak,
        'avgMood': avgMood,
        'unreadNotifs': notifs,
        'lastMood': moods.isNotEmpty ? moods.first : null,
        'lastDass': dass.isNotEmpty ? dass.first : null,
      };
    } catch (_) { return {}; }
  }
}