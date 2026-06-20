import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/payment_service.dart';
import '../../models/payment_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_provider.dart';

import '../auth/login_screen.dart';
import '../subscription/subscription_screen.dart';
import '../stats/stats_screen.dart';
import '../articles/articles_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/notification_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<PaymentModel> _payments = [];
  bool _loadingPayments = false;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    if (!mounted) return;
    setState(() => _loadingPayments = true);
    final payments = await PaymentService.getPaymentHistory();
    if (!mounted) return;
    setState(() {
      _payments = payments;
      _loadingPayments = false;
    });
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Keluar?',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Kamu akan keluar dari akun MindCare.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      await context.read<UserProvider>().signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (r) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(user)),
          SliverToBoxAdapter(child: _buildPlanCard(user)),
          SliverToBoxAdapter(child: _buildStats(user)),
          SliverToBoxAdapter(child: _buildPaymentHistory()),
          SliverToBoxAdapter(child: _buildSettings(themeProvider, user)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeader(UserProvider user) {
    final isDark = AppTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF1A3A38), Color(0xFF0D2220)]
              : const [Color(0xFF4ECDC4), Color(0xFF2BAD9E)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profil',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        onPressed: () => _showEditProfile(user),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user.avatarEmoji,
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 12),
              Text(
                user.displayName,
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                AuthService.currentUser?.email ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 8),
              // (upgrade/premium UI dihapus saat premium aktif sesuai permintaan)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.isPremium ? '✨' : '🌿',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.isPremium ? 'Premium' : 'Gratis',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(UserProvider user) {
    // Saat premium aktif, hapus seluruh tampilan upgrade premium di profil.
    if (user.isPremium) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SubscriptionScreen(),
          ),
        ).then((_) => context.read<UserProvider>().refreshPremiumStatus()),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF6C5CE7).withOpacity(0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('✨', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade ke Premium',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text(context),
                      ),
                    ),
                    Text(
                      'AI Chatbot • Statistik • PDF Export • Tanpa iklan',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppTheme.textMed(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Upgrade',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(UserProvider user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _mini('Paket', user.plan, '💎', AppTheme.purple),
          const SizedBox(width: 10),
          _mini(
            'Bergabung',
            DateFormat('MMM yyyy', 'id').format(user.user?.createdAt ?? DateTime.now()),
            '📅',
            AppTheme.teal,
          ),
          const SizedBox(width: 10),
          _mini(
            'Pembayaran',
            '${_payments.where((p) => p.status == 'paid').length}',
            '💳',
            AppTheme.gold,
          ),
        ],
      ),
    );
  }

  Widget _mini(String label, String val, String emoji, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              val,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: AppTheme.textMed(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory() {
    if (_loadingPayments) return const SizedBox.shrink();
    if (_payments.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Pembayaran',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card(context),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: _payments
                  .take(5)
                  .toList()
                  .asMap()
                  .entries
                  .map((e) {
                final p = e.value;
                final isLast =
                    e.key == (_payments.length > 5 ? 4 : _payments.length - 1);

                final statusColor = p.status == 'paid'
                    ? AppTheme.success
                    : p.status == 'pending'
                        ? AppTheme.warning
                        : AppTheme.danger;

                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          p.status == 'paid'
                              ? Icons.check_circle_outline
                              : p.status == 'pending'
                                  ? Icons.schedule
                                  : Icons.cancel_outlined,
                          color: statusColor,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        'Rp ${p.amount}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text(context),
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('d MMM yyyy, HH:mm', 'id').format(
                          (p.createdAt != null && p.createdAt!.isNotEmpty)
                              ? DateTime.tryParse(p.createdAt!) ?? DateTime.now()
                              : DateTime.now(),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.textLt(context),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (p.status == 'paid'
                                  ? 'Paid'
                                  : p.status == 'pending'
                                      ? 'Pending'
                                      : p.status)
                              .toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 70,
                        color: AppTheme.divider(context),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(ThemeProvider themeProvider, UserProvider user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pengaturan', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          _group([
            _item(
              Icons.bar_chart_rounded,
              'Statistik & Grafik',
              AppTheme.primary,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              ),
            ),
            _item(
              Icons.article_rounded,
              'Artikel Edukasi',
              AppTheme.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArticlesScreen()),
              ),
            ),
            _item(
              Icons.notifications_active_outlined,
              'Notifikasi',
              AppTheme.warning,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (themeProvider.isDark
                          ? Colors.indigo
                          : const Color(0xFFFFB347))
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  themeProvider.isDark
                      ? Icons.dark_mode_rounded
                      : Icons.wb_sunny_rounded,
                  color: themeProvider.isDark
                      ? Colors.indigo
                      : const Color(0xFFFFB347),
                  size: 22,
                ),
              ),
              title: Text(
                'Mode Gelap',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.text(context),
                ),
              ),
              subtitle: Text(
                themeProvider.isDark ? 'Aktif' : 'Nonaktif',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.textLt(context),
                ),
              ),
              value: themeProvider.isDark,
              onChanged: (v) => themeProvider.toggle(v),
            ),
          ),
          const SizedBox(height: 14),
          _group([
            _item(Icons.security_outlined, 'Keamanan & Privasi',
                AppTheme.success, () {}),
            _item(Icons.help_outline_rounded, 'Bantuan & FAQ', AppTheme.teal,
                () {}),
            _item(Icons.info_outline_rounded, 'Tentang MindCare',
                AppTheme.textMedium, () {
              showAboutDialog(
                context: context,
                applicationName: 'MindCare',
                applicationVersion: '2.0.0',
                applicationLegalese: '© 2025 MindCare · Kelompok 9 · ST Bhinneka',
              );
            }),
          ]),
          const SizedBox(height: 14),
          _group([
            _item(Icons.logout_rounded, 'Keluar', AppTheme.danger, _logout),
          ]),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'MindCare v2.0.0 · Dibuat dengan 💙 oleh Kelompok 9',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppTheme.textLt(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 68,
                  color: AppTheme.divider(context),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _item(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.text(context),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 13,
        color: AppTheme.textLt(context),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  void _showEditProfile(UserProvider user) {
    final nameCtrl = TextEditingController(text: user.displayName);
    final phoneCtrl = TextEditingController(text: user.user?.phone ?? '');
    final cityCtrl = TextEditingController(text: user.user?.city ?? '');

    String selected = user.avatarEmoji;
    final avatars = [
      '😊',
      '🌸',
      '🌿',
      '⭐',
      '🦋',
      '🌈',
      '🐸',
      '🦊',
      '🐼',
      '🦁',
      '🦄',
      '🎮'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.fromLTRB(
            22,
            22,
            22,
            MediaQuery.of(ctx).viewInsets.bottom + 22,
          ),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textLt(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Edit Profil',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Avatar',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.text(context),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: avatars
                    .map(
                      (a) => GestureDetector(
                        onTap: () => setS(() => selected = a),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected == a
                                ? AppTheme.primary.withOpacity(0.15)
                                : AppTheme.card2(context),
                            border: Border.all(
                              color: selected == a ? AppTheme.primary : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              a,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nama lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Nomor HP',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(
                  hintText: 'Kota',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await user.updateProfile(
                      fullName: nameCtrl.text.trim(),
                      avatarEmoji: selected,
                      phone: phoneCtrl.text.trim(),
                      city: cityCtrl.text.trim(),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

