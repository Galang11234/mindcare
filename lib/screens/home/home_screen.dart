import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../services/cloud_service.dart';

import '../../utils/app_theme.dart';

import '../subscription/subscription_screen.dart';
import '../dass/dass_screen.dart';
import '../chat/chat_screen.dart';
import '../psychologists/psychologist_screen.dart';

import '../stats/stats_screen.dart';
import '../articles/articles_screen.dart';
import '../profile/notification_settings_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pastikan data dashboard mengikuti perubahan di provider (mis. setelah payment premium)
    // tanpa harus restart aplikasi.
    final user = context.read<UserProvider>();
    if (!_loading && user.isLoggedIn) {
      _load();
    }
  }



  Future<void> _load() async {
    final stats = await CloudService.getDashboardStats();
    if (mounted) setState(() { _stats = stats; _loading = false; });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat Pagi';
    if (h < 17) return 'Selamat Siang';
    if (h < 20) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(user)),
            // Premium banner dihapus setelah user premium aktif (sesuai permintaan) 
            // Banner dihapus saat user premium aktif
            if (!user.isPremium)
              SliverToBoxAdapter(child: _buildPremiumBanner()),
            SliverToBoxAdapter(child: _buildStatCards()),
            SliverToBoxAdapter(child: _buildQuickActions(user)),
            SliverToBoxAdapter(child: _buildStreakWidget()),
            SliverToBoxAdapter(child: _buildLastMood()),
            SliverToBoxAdapter(child: _buildServices()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader(UserProvider user) {
    final isDark = AppTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3A38), const Color(0xFF0D2220)]
              : [const Color(0xFF4ECDC4), const Color(0xFF2BAD9E)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${_greeting()},', style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.white.withOpacity(0.8))),
                Text(user.displayName, style: GoogleFonts.nunito(
                    fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
              ]),
              Row(children: [
                // Notif bell
                GestureDetector(
                  onTap: () => Navigator.push(context,
MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),

                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: Stack(children: [
                      const Center(child: Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 22)),
                      if ((_stats['unreadNotifs'] ?? 0) > 0)
                        Positioned(right: 8, top: 8,
                          child: Container(
                            width: 9, height: 9,
                            decoration: const BoxDecoration(
                              color: AppTheme.danger, shape: BoxShape.circle))),
                    ]),
                  ),
                ),
                const SizedBox(width: 10),
                // Avatar
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25), shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2)),
                  child: Stack(children: [
                    Center(child: Text(user.avatarEmoji,
                        style: const TextStyle(fontSize: 24))),
                    if (user.isPremium)
                      Positioned(right: 0, bottom: 0,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B), shape: BoxShape.circle),
                          child: const Center(child: Text('✨',
                              style: TextStyle(fontSize: 8))))),
                  ]),
                ),
              ]),
            ]),
            const SizedBox(height: 18),
            // Today's date + mood card
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ChatScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.3))),
                child: Row(children: [
                  Text(_stats['lastMood']?['emoji'] ?? '🌿',
                      style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _stats['lastMood'] != null
                            ? 'Mood: ${_stats['lastMood']['mood_label']}'
                            : 'Hai! Bagaimana perasaanmu hari ini?',
                        style: GoogleFonts.poppins(
                            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text(
                        _stats['lastMood'] != null
                            ? DateFormat('EEEE, d MMM · HH:mm', 'id')
                                .format(DateTime.parse(_stats['lastMood']['recorded_at']))
                            : 'Ketuk untuk mulai curhat 💬',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.white.withOpacity(0.7))),
                    ])),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Premium Banner ────────────────────────────────────────────
  Widget _buildPremiumBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SubscriptionScreen())).then((_) => _load()),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.35),
            blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          const Text('✨', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Upgrade ke Premium', style: GoogleFonts.nunito(
                fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            Text('AI Chatbot unlimited · Statistik advanced · Export PDF · Tanpa iklan',
                style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.white.withOpacity(0.85))),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)),
            child: Text('Rp29.900/bl', style: GoogleFonts.poppins(
                fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF6C5CE7))),
          ),
        ]),
      ),
    );
  }

  // ── Stat Cards ────────────────────────────────────────────────
  Widget _buildStatCards() {
    final stats = [
      {'label': 'Mood\nDicatat', 'val': '${_stats['moodCount'] ?? 0}', 'emoji': '😊', 'color': AppTheme.teal},
      {'label': 'Entri\nJurnal', 'val': '${_stats['journalCount'] ?? 0}', 'emoji': '✍️', 'color': AppTheme.purple},
      {'label': 'Tes\nDASS', 'val': '${_stats['dassCount'] ?? 0}', 'emoji': '🧠', 'color': AppTheme.orange},
      {'label': 'Rata-rata\nMood', 'val': (_stats['avgMood'] ?? 0.0) == 0.0 ? '-' : (_stats['avgMood'] as double).toStringAsFixed(1), 'emoji': '⭐', 'color': AppTheme.gold},
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(children: stats.asMap().entries.map((e) {
        final s = e.value;
        final c = s['color'] as Color;
        return Expanded(child: Container(
          margin: EdgeInsets.only(right: e.key < 3 ? 10 : 0),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.card(context), borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(s['emoji'] as String, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(s['val'] as String, style: GoogleFonts.nunito(
                fontSize: 20, fontWeight: FontWeight.w800, color: c)),
            Text(s['label'] as String, textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 9.5,
                    color: AppTheme.textMed(context), height: 1.3)),
          ]),
        ));
      }).toList()),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────
  Widget _buildQuickActions(UserProvider user) {
    final actions = [
      _QA('🧠', 'Tes Mental', 'DASS-21', const Color(0xFF6C5CE7),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DassScreen()))),
      _QA('💬', 'Chat AI', 'Curhat yuk', const Color(0xFF00B894),
          () {
            if (!user.requirePremium(context, feature: 'AI Chatbot tanpa batas')) return;
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
          }),
      _QA('👨‍⚕️', 'Psikolog', 'Booking sesi', const Color(0xFFFF6B6B),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PsychologistScreen()))),
      _QA('📊', 'Statistik', 'Lihat grafik', const Color(0xFFF59E0B),
          () {
            if (!user.requirePremium(context, feature: 'Statistik advanced')) return;
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
          }),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Aksi Cepat', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        Row(children: actions.map((a) => Expanded(child: GestureDetector(
          onTap: a.onTap,
          child: Container(
            margin: EdgeInsets.only(right: a == actions.last ? 0 : 10),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            decoration: BoxDecoration(
              color: a.color.withOpacity(AppTheme.isDark(context) ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: a.color.withOpacity(0.25))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(a.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(a.title, style: GoogleFonts.poppins(fontSize: 11,
                  fontWeight: FontWeight.w700, color: AppTheme.text(context))),
              Text(a.sub, style: GoogleFonts.poppins(fontSize: 9,
                  color: a.color, fontWeight: FontWeight.w600)),
            ]),
          ),
        ))).toList()),
      ]),
    );
  }

  // ── Streak ───────────────────────────────────────────────────
  Widget _buildStreakWidget() {
    final streak = _stats['streak'] ?? 0;
    if (streak == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFE066), Color(0xFFFFB347)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: const Color(0xFFFFB347).withOpacity(0.3),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          const Text('🔥', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$streak Hari Berturut-turut!', style: GoogleFonts.nunito(
                fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF7A4800))),
            Text('Luar biasa! Terus jaga konsistensimu ya 💪',
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF7A4800).withOpacity(0.8))),
          ])),
          Column(children: List.generate(streak > 7 ? 7 : streak, (i) =>
            const Text('🔥', style: TextStyle(fontSize: 10))).take(7).toList()),
        ]),
      ),
    );
  }

  // ── Last Mood Week ────────────────────────────────────────────
  Widget _buildLastMood() {
    final lastMood = _stats['lastMood'];
    if (lastMood == null) return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.teal.withOpacity(0.3), style: BorderStyle.solid),
        ),
        child: Row(children: [
          const Text('📊', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Belum ada data mood', style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: AppTheme.text(context))),
            Text('Mulai catat moodmu hari ini dari tab Mood!',
                style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMed(context))),
          ])),
        ]),
      ),
    );
    return const SizedBox.shrink();
  }

  // ── Services (Psikolog / B2B) ─────────────────────────────────
  Widget _buildServices() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Layanan MindCare', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        // Konsultasi Psikolog
        _ServiceCard(
          icon: '👨‍⚕️',
          title: 'Konsultasi Psikolog',
          desc: 'Book sesi 1-on-1 dengan psikolog berlisensi. Video call, voice, atau chat.',
          badge: 'Mulai Rp150rb/sesi',
          badgeColor: AppTheme.teal,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PsychologistScreen())),
        ),
        const SizedBox(height: 12),
        // Premium
        _ServiceCard(
          icon: '✨',
          title: 'MindCare Premium',
          desc: 'AI Chatbot tanpa batas, statistik advanced, export laporan PDF, tanpa iklan.',
          badge: 'Rp29.900/bulan',
          badgeColor: const Color(0xFF6C5CE7),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SubscriptionScreen())).then((_) => _load()),
        ),
        const SizedBox(height: 12),
        // Artikel
        _ServiceCard(
          icon: '📚',
          title: 'Artikel Edukasi',
          desc: 'Tips & panduan kesehatan mental berbasis bukti ilmiah. Update mingguan.',
          badge: 'Gratis',
          badgeColor: AppTheme.success,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ArticlesScreen())),
        ),
      ]),
    );
  }
}

class _QA {
  final String emoji, title, sub;
  final Color color;
  final VoidCallback onTap;
  const _QA(this.emoji, this.title, this.sub, this.color, this.onTap);
}

class _ServiceCard extends StatelessWidget {
  final String icon, title, desc, badge;
  final Color badgeColor;
  final VoidCallback onTap;
  const _ServiceCard({required this.icon, required this.title, required this.desc,
    required this.badge, required this.badgeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card(context), borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(title, style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text(context))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor, borderRadius: BorderRadius.circular(8)),
                child: Text(badge, style: GoogleFonts.poppins(
                    fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(desc, style: GoogleFonts.poppins(
                fontSize: 11.5, color: AppTheme.textMed(context))),
          ])),
          Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textLt(context)),
        ]),
      ),
    );
  }
}