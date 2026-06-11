// lib/screens/subscription/subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/payment_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlan = 'premium_annual';
  bool _isPremium = false;
  bool _loading = false;
  bool _checkingStatus = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final premium = await PaymentService.isPremium();
    if (mounted) setState(() { _isPremium = premium; _checkingStatus = false; });
  }

  Future<void> _subscribe() async {
    final user = await AuthService.getUserProfile();
    if (user == null) return;

    setState(() => _loading = true);

    final result = await PaymentService.createPayment(
      planId: _selectedPlan,
      userFullName: user.fullName,
      userEmail: user.email,
      userPhone: user.phone ?? '08100000000',
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      // Open Midtrans payment page
      await PaymentService.openPaymentPage(result.paymentUrl!);
      // Show waiting dialog
      _showWaitingDialog(result.orderId!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.error ?? 'Gagal memproses pembayaran'),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _showWaitingDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PaymentStatusDialog(orderId: orderId),
    ).then((_) => _checkStatus());
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingStatus) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          if (_isPremium)
            SliverToBoxAdapter(child: _buildActiveStatus())
          else ...[
            SliverToBoxAdapter(child: _buildPlans()),
            SliverToBoxAdapter(child: _buildFeatureComparison()),
            SliverToBoxAdapter(child: _buildB2BSection()),
            SliverToBoxAdapter(child: _buildCTA()),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: AppTheme.isDark(context)
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFF6C5CE7), const Color(0xFFA855F7)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(children: [
            Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
            const SizedBox(height: 8),
            const Text('✨', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text('MindCare Premium', style: GoogleFonts.nunito(
                fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Dapatkan akses penuh ke semua fitur\ndan mulai perjalanan mentalmu lebih serius.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.white.withOpacity(0.85))),
          ]),
        ),
      ),
    );
  }

  // ── Active Status ────────────────────────────────────────────
  Widget _buildActiveStatus() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(children: [
          const Text('👑', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('Kamu sudah Premium! 🎉', style: GoogleFonts.nunito(
              fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Nikmati semua fitur MindCare tanpa batas.\nTerima kasih sudah jadi bagian MindCare! 💙',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Kembali ke Beranda'),
          ),
        ]),
      ),
    );
  }

  // ── Plans ────────────────────────────────────────────────────
  Widget _buildPlans() {
    final planList = ['premium_monthly', 'premium_annual'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Pilih Paket', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        ...planList.map((planId) {
          final plan = PaymentService.plans[planId]!;
          final isSelected = _selectedPlan == planId;
          return GestureDetector(
            onTap: () => setState(() => _selectedPlan = planId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C5CE7).withOpacity(0.12)
                    : AppTheme.card(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF6C5CE7) : AppTheme.divider(context),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(children: [
                // Radio
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF6C5CE7) : Colors.transparent,
                    border: Border.all(
                        color: isSelected ? const Color(0xFF6C5CE7) : AppTheme.textLt(context),
                        width: 2),
                  ),
                  child: isSelected
                      ? const Center(child: Icon(Icons.check, size: 13, color: Colors.white))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(plan.name, style: GoogleFonts.nunito(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: AppTheme.text(context))),
                    if (plan.isBestValue) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('TERBAIK', style: GoogleFonts.poppins(
                            fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Text(plan.period, style: GoogleFonts.poppins(
                      fontSize: 12, color: AppTheme.textMed(context))),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(plan.formattedPrice, style: GoogleFonts.nunito(
                      fontSize: 20, fontWeight: FontWeight.w800,
                      color: const Color(0xFF6C5CE7))),
                  if (plan.originalPrice != null)
                    Text(plan.formattedOriginal, style: GoogleFonts.poppins(
                        fontSize: 11, color: AppTheme.textLt(context),
                        decoration: TextDecoration.lineThrough)),
                  if (plan.discountPercent != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Hemat ${plan.discountPercent}%',
                          style: GoogleFonts.poppins(fontSize: 9,
                              color: AppTheme.danger, fontWeight: FontWeight.w600)),
                    ),
                ]),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  // ── Feature Comparison ───────────────────────────────────────
  Widget _buildFeatureComparison() {
    final features = [
      ['Mood Tracker', true, true],
      ['Jurnal Harian', true, true],
      ['Tes DASS-21', true, true],
      ['Artikel (dasar)', true, true],
      ['Relaksasi (2 latihan)', true, false],
      ['AI Chatbot (10 pesan/hari)', true, false],
      ['Iklan ditampilkan', false, true],
      ['Semua latihan relaksasi (6+)', true, false],
      ['AI Chatbot tanpa batas', true, false],
      ['Statistik advanced + grafik', true, false],
      ['Export laporan PDF', true, false],
      ['Artikel premium eksklusif', true, false],
      ['Tanpa iklan', true, false],
      ['Priority support', true, false],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Perbandingan Fitur', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card(context), borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(children: [
                Expanded(child: Text('Fitur', style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
                SizedBox(width: 70, child: Text('Premium', textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
                SizedBox(width: 50, child: Text('Gratis', textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
              ]),
            ),
            ...features.asMap().entries.map((entry) {
              final i = entry.key;
              final f = entry.value;
              final featureName = f[0] as String;
              final hasPremium = f[1] as bool;
              final hasFree = f[2] as bool;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: i % 2 == 0 ? Colors.transparent : AppTheme.bg(context).withOpacity(0.5),
                ),
                child: Row(children: [
                  Expanded(child: Text(featureName, style: GoogleFonts.poppins(
                      fontSize: 12.5, color: AppTheme.text(context)))),
                  SizedBox(width: 70, child: Center(child: Icon(
                    hasPremium ? Icons.check_circle : Icons.cancel,
                    size: 18,
                    color: hasPremium ? AppTheme.success : AppTheme.textLt(context)))),
                  SizedBox(width: 50, child: Center(child: Icon(
                    hasFree ? Icons.check_circle : Icons.cancel,
                    size: 18,
                    color: hasFree ? AppTheme.success : AppTheme.textLt(context)))),
                ]),
              );
            }),
          ]),
        ),
      ]),
    );
  }

  // ── B2B Section ──────────────────────────────────────────────
  Widget _buildB2BSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Untuk Institusi', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF0D3B4A), Color(0xFF164E63)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🏢', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text('Paket Kampus & Korporat', style: GoogleFonts.nunito(
                fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Mulai dari Rp 5.000.000 / tahun', style: GoogleFonts.poppins(
                fontSize: 14, color: AppTheme.gold, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...['Dashboard admin & laporan kolektif anonim',
              'Akun unlimited untuk seluruh mahasiswa/karyawan',
              'Laporan kesehatan mental agregat tiap bulan',
              'Integrasi SSO kampus/perusahaan',
              'Dedicated account manager',
            ].map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Icon(Icons.check_circle, color: AppTheme.teal, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(f, style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.white70))),
              ]),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.mail_outline, size: 16),
                label: const Text('Hubungi Tim Sales'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.teal,
                  side: BorderSide(color: AppTheme.teal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // launch mailto or WhatsApp
                },
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── CTA Button ───────────────────────────────────────────────
  Widget _buildCTA() {
    final plan = PaymentService.plans[_selectedPlan]!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _subscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: _loading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('✨  ', style: TextStyle(fontSize: 18)),
                    Text('Berlangganan ${plan.formattedPrice}/${plan.period}',
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
          ),
        ),
        const SizedBox(height: 12),
        Text('Pembayaran aman via Midtrans · GoPay · OVO · QRIS · Transfer Bank',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textLt(context))),
        const SizedBox(height: 6),
        Text('Bisa dibatalkan kapan saja · Tidak ada biaya tersembunyi',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textLt(context))),
        const SizedBox(height: 20),
        // Payment method icons
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (final method in ['GoPay', 'OVO', 'DANA', 'QRIS', 'BCA', 'Mandiri'])
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.divider(context)),
              ),
              child: Text(method, style: GoogleFonts.poppins(
                  fontSize: 9.5, fontWeight: FontWeight.w600, color: AppTheme.textMed(context))),
            ),
        ]),
      ]),
    );
  }
}

// ── Payment Status Dialog ─────────────────────────────────────
class _PaymentStatusDialog extends StatefulWidget {
  final String orderId;
  const _PaymentStatusDialog({required this.orderId});
  @override
  State<_PaymentStatusDialog> createState() => _PaymentStatusDialogState();
}

class _PaymentStatusDialogState extends State<_PaymentStatusDialog> {
  String _status = 'pending';
  bool _checking = false;

  Future<void> _checkStatus() async {
    setState(() => _checking = true);
    final status = await PaymentService.checkPaymentStatus(widget.orderId);
    if (mounted) setState(() { _status = status; _checking = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = _status == 'paid';
    return AlertDialog(
      backgroundColor: AppTheme.card(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(isPaid ? '🎉' : '⏳', style: const TextStyle(fontSize: 52)),
        const SizedBox(height: 12),
        Text(
          isPaid ? 'Pembayaran Berhasil!' : 'Menunggu Pembayaran',
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800,
              color: AppTheme.text(context)),
        ),
        const SizedBox(height: 8),
        Text(
          isPaid
              ? 'Premium MindCare kamu sudah aktif! Nikmati semua fitur tanpa batas. 💙'
              : 'Selesaikan pembayaran di halaman yang sudah dibuka, lalu tap "Cek Status".',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMed(context)),
        ),
        const SizedBox(height: 20),
        if (!isPaid) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checking ? null : _checkStatus,
              child: _checking
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('🔄  Cek Status Pembayaran'),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isPaid ? 'Mulai Pakai Premium!' : 'Nanti Saja',
              style: GoogleFonts.poppins(color: AppTheme.primary)),
        ),
      ]),
    );
  }
}
