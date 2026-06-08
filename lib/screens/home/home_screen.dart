import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/storage_service.dart';
import '../../models/models.dart';
import '../../utils/app_theme.dart';
import '../../data/article_data.dart';
import '../dass/dass_screen.dart';
import '../chat/chat_screen.dart';
import '../articles/articles_screen.dart';
import '../articles/article_detail_screen.dart';
import '../stats/stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _user;
  MoodEntry? _lastMood;
  List<MoodEntry> _weekMoods = [];
  int _streakDays = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await StorageService.getUser();
    final moods = await StorageService.getMoodEntries();
    if (mounted) {
      setState(() {
        _user = user;
        _lastMood = moods.isNotEmpty ? moods.first : null;
        _weekMoods = moods.take(7).toList();
        _streakDays = _calcStreak(moods);
        _loading = false;
      });
    }
  }

  int _calcStreak(List<MoodEntry> moods) {
    if (moods.isEmpty) return 0;
    int streak = 0;
    DateTime day = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final target = DateTime(day.year, day.month, day.day - i);
      final hasEntry = moods.any((m) =>
          m.date.year == target.year &&
          m.date.month == target.month &&
          m.date.day == target.day);
      if (hasEntry) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat Pagi';
    if (h < 17) return 'Selamat Siang';
    if (h < 20) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  Color _moodColor(int level) {
    switch (level) {
      case 5: return AppTheme.moodGreat;
      case 4: return AppTheme.moodGood;
      case 3: return AppTheme.moodOkay;
      case 2: return AppTheme.moodBad;
      default: return AppTheme.moodTerrible;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(backgroundColor: AppTheme.bg(context),
        body: const Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildStreakBanner()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildMoodWeek()),
            SliverToBoxAdapter(child: _buildArticles()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final isDark = AppTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3A38), const Color(0xFF0D2220)]
              : [const Color(0xFF4ECDC4), const Color(0xFF2BAD9E)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_getGreeting()},',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.white.withOpacity(0.8))),
                    Text(_user?.name ?? 'Pengguna',
                        style: GoogleFonts.nunito(
                            fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                  ]),
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                    ),
                    child: Center(child: Text(_user?.avatarEmoji ?? '😊',
                        style: const TextStyle(fontSize: 28))),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Mood card
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChatScreen())),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Text(_lastMood?.emoji ?? '🌿',
                        style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        _lastMood != null ? 'Mood terakhir: ${_lastMood!.moodLabel}' : 'Bagaimana perasaanmu?',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      Text(
                        _lastMood != null
                            ? DateFormat('EEEE, d MMM · HH:mm', 'id').format(_lastMood!.date)
                            : 'Ketuk untuk mulai curhat 💬',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.white.withOpacity(0.7)),
                      ),
                    ])),
                    const Icon(Icons.chevron_right, color: Colors.white70),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Streak Banner ───────────────────────────────────────────────────────────
  Widget _buildStreakBanner() {
    if (_streakDays == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFFE066), Color(0xFFFFB347)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: const Color(0xFFFFB347).withOpacity(0.3),
                blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(children: [
          const Text('🔥', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$_streakDays Hari Berturut-turut! 🎉',
                style: GoogleFonts.nunito(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: const Color(0xFF7A4800))),
            Text('Pertahankan kebiasaan baik ini! Kamu luar biasa.',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: const Color(0xFF7A4800).withOpacity(0.8))),
          ])),
        ]),
      ),
    );
  }

  // ── Quick Actions ───────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      _Action('🧠', 'Tes Mental', 'DASS-21', const Color(0xFF6C5CE7),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DassScreen())).then((_) => _loadData())),
      _Action('💬', 'Chat AI', 'Curhat yuk', const Color(0xFF00B894),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
      _Action('📊', 'Statistik', 'Grafik mood', const Color(0xFFFF6B6B),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()))),
      _Action('📚', 'Artikel', 'Baca yuk', const Color(0xFFFFB347),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesScreen()))),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aksi Cepat', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          Row(
            children: actions.map((a) => Expanded(
              child: GestureDetector(
                onTap: a.onTap,
                child: Container(
                  margin: EdgeInsets.only(right: a == actions.last ? 0 : 10),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: a.color.withOpacity(AppTheme.isDark(context) ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: a.color.withOpacity(0.25)),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(a.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(a.title, style: GoogleFonts.poppins(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppTheme.text(context))),
                    Text(a.sub, style: GoogleFonts.poppins(
                        fontSize: 9, color: a.color, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ── Mood Week ───────────────────────────────────────────────────────────────
  Widget _buildMoodWeek() {
    if (_weekMoods.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mood 7 Hari', style: Theme.of(context).textTheme.headlineSmall),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StatsScreen())),
                child: Text('Lihat semua →',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: AppTheme.card(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekMoods.take(7).map((m) => Column(children: [
                Text(m.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: _moodColor(m.moodLevel), shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(DateFormat('d/M').format(m.date),
                    style: GoogleFonts.poppins(
                        fontSize: 9, color: AppTheme.textLt(context))),
              ])).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Articles ────────────────────────────────────────────────────────────────
  Widget _buildArticles() {
    final articles = ArticleData.articles.take(3).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Artikel untuk Kamu', style: Theme.of(context).textTheme.headlineSmall),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ArticlesScreen())),
                child: Text('Semua →',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...articles.map((a) => GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: a))),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(children: [
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(a.emoji, style: const TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text(context))),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(a.category,
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.timer_outlined, size: 11, color: AppTheme.textLt(context)),
                    const SizedBox(width: 2),
                    Text('${a.readMinutes} menit',
                        style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textLt(context))),
                  ]),
                ])),
                Icon(Icons.arrow_forward_ios, size: 13, color: AppTheme.textLt(context)),
              ]),
            ),
          )),
        ],
      ),
    );
  }
}

class _Action {
  final String emoji, title, sub;
  final Color color;
  final VoidCallback onTap;
  const _Action(this.emoji, this.title, this.sub, this.color, this.onTap);
}