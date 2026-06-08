import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_provider.dart';
import '../auth/login_screen.dart';
import '../stats/stats_screen.dart';
import '../articles/articles_screen.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _user;
  int _moodCount = 0, _journalCount = 0, _dassCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await StorageService.getUser();
    final moods = await StorageService.getMoodEntries();
    final journals = await StorageService.getJournalEntries();
    final dass = await StorageService.getDassResults();
    if (mounted) setState(() {
      _user = user;
      _moodCount = moods.length;
      _journalCount = journals.length;
      _dassCount = dass.length;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Keluar?', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text('Kamu akan keluar dari akun MindCare.',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Keluar', style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.setLoggedIn(false);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
    }
  }

  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Semua Data?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppTheme.danger)),
        content: Text(
            'Semua data mood, jurnal, dan tes akan dihapus permanen. Aksi ini tidak bisa dibatalkan!',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus', style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.clearAll();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: const Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildStats()),
          SliverToBoxAdapter(child: _buildMenuSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = AppTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Profil',
                  style: GoogleFonts.nunito(
                      fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: _showEditProfile,
              ),
            ]),
            const SizedBox(height: 16),
            Stack(alignment: Alignment.bottomRight, children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                ),
                child: Center(child: Text(_user?.avatarEmoji ?? '😊',
                    style: const TextStyle(fontSize: 48))),
              ),
              GestureDetector(
                onTap: _showEditProfile,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Text(_user?.name ?? 'Pengguna',
                style: GoogleFonts.nunito(
                    fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(_user?.email ?? '',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.75))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Bergabung ${DateFormat('MMMM yyyy', 'id').format(_user?.createdAt ?? DateTime.now())}',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.white.withOpacity(0.85)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(children: [
        _StatCard('$_moodCount', 'Mood\nDicatat', '😊', AppTheme.moodGood, context),
        const SizedBox(width: 10),
        _StatCard('$_journalCount', 'Entri\nJurnal', '✍️', AppTheme.purple, context),
        const SizedBox(width: 10),
        _StatCard('$_dassCount', 'Tes\nDASS', '🧠', AppTheme.orange, context),
      ]),
    );
  }

  Widget _buildMenuSection() {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Menu', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),

        // Navigasi
        _MenuGroup(items: [
          _MenuItem(Icons.bar_chart_rounded, 'Statistik & Grafik',
              'Lihat perkembangan mentalmu', AppTheme.primary, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
          }),
          _MenuItem(Icons.article_rounded, 'Artikel Edukasi',
              'Baca tips kesehatan mental', AppTheme.purple, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesScreen()));
          }),
          _MenuItem(Icons.notifications_active_outlined, 'Notifikasi Harian',
              'Pengingat mood & jurnal', AppTheme.warning, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()));
          }),
        ]),
        const SizedBox(height: 14),

        // Dark Mode toggle — menggunakan Provider, langsung toggle tema aplikasi
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SwitchListTile(
            secondary: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: (isDark ? Colors.indigo : const Color(0xFFFFB347)).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.wb_sunny_rounded,
                  color: isDark ? Colors.indigo : const Color(0xFFFFB347),
                  size: 22,
                ),
              ),
            ),
            title: Text('Mode Gelap',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.text(context))),
            subtitle: Text(isDark ? 'Aktif — tema gelap' : 'Nonaktif — tema terang',
                style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textLt(context))),
            value: isDark,
            onChanged: (val) => themeProvider.toggle(val),
          ),
        ),
        const SizedBox(height: 14),

        // Bahaya
        _MenuGroup(items: [
          _MenuItem(Icons.delete_sweep_outlined, 'Hapus Semua Data',
              'Reset seluruh riwayat', AppTheme.danger, _clearData),
          _MenuItem(Icons.logout_rounded, 'Keluar',
              'Logout dari akunmu', AppTheme.danger, _logout),
        ]),
        const SizedBox(height: 20),

        // Version
        Center(child: Text('MindCare v1.0.0 · Dibuat dengan 💙',
            style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textLt(context)))),
      ]),
    );
  }

  void _showEditProfile() {
    final nameCtrl = TextEditingController(text: _user?.name ?? '');
    final avatars = ['😊','🌸','🌿','⭐','🦋','🌈','🐸','🦊','🐼','🦁','🐯','🦄'];
    String selected = _user?.avatarEmoji ?? '😊';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.textLt(context),
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Edit Profil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text('Pilih Avatar', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14,
                color: AppTheme.text(context))),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: avatars.map((a) => GestureDetector(
              onTap: () => setS(() => selected = a),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected == a ? AppTheme.primary.withOpacity(0.18) : AppTheme.card2(context),
                  border: Border.all(
                    color: selected == a ? AppTheme.primary : Colors.transparent, width: 2.5),
                ),
                child: Center(child: Text(a, style: const TextStyle(fontSize: 26))),
              ),
            )).toList()),
            const SizedBox(height: 18),
            Text('Nama', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14,
                color: AppTheme.text(context))),
            const SizedBox(height: 8),
            TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Nama kamu')),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity,
              child: ElevatedButton(onPressed: () async {
                if (_user != null) {
                  _user!.name = nameCtrl.text.trim().isEmpty ? _user!.name : nameCtrl.text.trim();
                  _user!.avatarEmoji = selected;
                  await StorageService.saveUser(_user!);
                  _load();
                }
                Navigator.pop(ctx);
              }, child: const Text('Simpan Perubahan')),
            ),
          ],
        ),
      )),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value, label, emoji;
  final Color color;
  final BuildContext ctx;
  const _StatCard(this.value, this.label, this.emoji, this.color, this.ctx);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.card(ctx),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.nunito(
              fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          Text(label, textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: AppTheme.textMed(ctx), height: 1.3)),
        ]),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGroup({required this.items});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context), borderRadius: BorderRadius.circular(18)),
      child: Column(children: items.asMap().entries.map((e) {
        final item = e.value;
        final isLast = e.key == items.length - 1;
        return Column(children: [
          ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            title: Text(item.title,
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.text(context))),
            subtitle: Text(item.subtitle,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppTheme.textLt(context))),
            trailing: Icon(Icons.arrow_forward_ios, size: 13,
                color: AppTheme.textLt(context)),
            onTap: item.onTap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: e.key == 0 ? const Radius.circular(18) : Radius.zero,
                bottom: isLast ? const Radius.circular(18) : Radius.zero,
              ),
            ),
          ),
          if (!isLast) Divider(height: 1, indent: 68, color: AppTheme.divider(context)),
        ]);
      }).toList()),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.title, this.subtitle, this.color, this.onTap);
}