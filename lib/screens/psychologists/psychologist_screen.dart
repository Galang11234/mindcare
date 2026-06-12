// lib/screens/psychologist/psychologist_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../utils/app_theme.dart';
import '../../../services/payment_service.dart';
import '../../../services/auth_service.dart';

class PsychologistScreen extends StatefulWidget {
  const PsychologistScreen({super.key});
  @override
  State<PsychologistScreen> createState() => _PsychologistScreenState();
}

class _PsychologistScreenState extends State<PsychologistScreen> {
  final _sb = Supabase.instance.client;
  List<Map<String, dynamic>> _psychologists = [];
  bool _loading = true;
  String _selectedSpec = 'Semua';

  final _specs = ['Semua', 'Kecemasan', 'Depresi', 'Stres', 'Hubungan', 'Trauma', 'Karir'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _sb
          .from('psychologists')
          .select()
          .eq('is_active', true)
          .eq('is_verified', true)
          .order('rating_avg', ascending: false);
      if (mounted) setState(() { _psychologists = List<Map<String,dynamic>>.from(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedSpec == 'Semua') return _psychologists;
    return _psychologists.where((p) {
      final specs = (p['specializations'] as List?)?.cast<String>() ?? [];
      return specs.any((s) => s.toLowerCase().contains(_selectedSpec.toLowerCase()));
    }).toList();
  }

  // Demo data saat DB kosong
  List<Map<String, dynamic>> get _demoData => [
    {
      'id': '1', 'full_name': 'Dr. Ayu Rahayu, M.Psi., Psikolog',
      'title': 'M.Psi., Psikolog', 'experience_years': 8,
      'specializations': ['Kecemasan', 'Depresi', 'Stres'],
      'session_price': 200000, 'rating_avg': 4.9, 'rating_count': 127,
      'bio': 'Psikolog klinis berpengalaman 8 tahun, spesialis kecemasan dan depresi. Menggunakan pendekatan CBT dan ACT.',
      'is_available': true, 'languages': ['Indonesia', 'English'],
    },
    {
      'id': '2', 'full_name': 'Budi Santoso, S.Psi., M.Psi.',
      'title': 'S.Psi., M.Psi.', 'experience_years': 5,
      'specializations': ['Hubungan', 'Trauma', 'Karir'],
      'session_price': 175000, 'rating_avg': 4.8, 'rating_count': 89,
      'bio': 'Konselor psikologi dengan keahlian dalam masalah hubungan interpersonal dan pengembangan diri.',
      'is_available': true, 'languages': ['Indonesia'],
    },
    {
      'id': '3', 'full_name': 'Siti Nurhaliza, Psi.',
      'title': 'Psi., Konselor', 'experience_years': 3,
      'specializations': ['Stres', 'Kecemasan', 'Mahasiswa'],
      'session_price': 150000, 'rating_avg': 4.7, 'rating_count': 54,
      'bio': 'Spesialis konseling mahasiswa dan dewasa muda. Pengalaman menangani stres akademik dan transisi kehidupan.',
      'is_available': false, 'languages': ['Indonesia'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final data = _psychologists.isEmpty ? _demoData : _filtered;
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text('Konsultasi Psikolog', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Column(children: [
        // Specialty filter
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _specs.length,
            itemBuilder: (_, i) {
              final spec = _specs[i];
              final active = _selectedSpec == spec;
              return GestureDetector(
                onTap: () => setState(() => _selectedSpec = spec),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.primary : AppTheme.card(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? AppTheme.primary : AppTheme.divider(context)),
                  ),
                  child: Center(child: Text(spec, style: GoogleFonts.poppins(
                      fontSize: 12.5, fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppTheme.textMed(context)))),
                ),
              );
            },
          ),
        ),

        // Info banner
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'MindCare mengambil komisi 20% per sesi. Psikolog menerima 80%.',
                style: GoogleFonts.poppins(fontSize: 11.5, color: AppTheme.primary),
              )),
            ]),
          ),
        ),

        // List
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (_, i) => _PsychCard(
                    psych: data[i],
                    onBook: () => _showBookingSheet(data[i]),
                  ),
                ),
        ),
      ]),
    );
  }

  void _showBookingSheet(Map<String, dynamic> psych) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(psych: psych),
    );
  }
}

// ── Psychologist Card ─────────────────────────────────────────
class _PsychCard extends StatelessWidget {
  final Map<String, dynamic> psych;
  final VoidCallback onBook;
  const _PsychCard({required this.psych, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final name = psych['full_name'] as String? ?? '';
    final title = psych['title'] as String? ?? '';
    final specs = (psych['specializations'] as List?)?.cast<String>() ?? [];
    final price = psych['session_price'] as int? ?? 0;
    final rating = (psych['rating_avg'] as num?)?.toDouble() ?? 0;
    final ratingCount = psych['rating_count'] as int? ?? 0;
    final exp = psych['experience_years'] as int? ?? 0;
    final available = psych['is_available'] as bool? ?? false;
    final bio = psych['bio'] as String? ?? '';

    final formattedPrice = 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.card(context), borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Avatar
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.teal, AppTheme.primaryDark]),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'P',
                style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: GoogleFonts.nunito(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text(context))),
              Text(title, style: GoogleFonts.poppins(
                  fontSize: 11, color: AppTheme.primary)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                const SizedBox(width: 3),
                Text('$rating ($ratingCount ulasan)',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMed(context))),
                const SizedBox(width: 12),
                const Icon(Icons.work_outline, size: 14, color: AppTheme.primary),
                const SizedBox(width: 3),
                Text('$exp tahun', style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMed(context))),
              ]),
            ])),
            // Available badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: available ? AppTheme.success.withOpacity(0.12) : AppTheme.textLt(context).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 7, height: 7,
                  decoration: BoxDecoration(
                    color: available ? AppTheme.success : AppTheme.textLt(context),
                    shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(available ? 'Online' : 'Offline',
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600,
                        color: available ? AppTheme.success : AppTheme.textLt(context))),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Text(bio, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMed(context))),
          const SizedBox(height: 10),
          // Specializations
          Wrap(spacing: 6, runSpacing: 6, children: specs.take(3).map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(s, style: GoogleFonts.poppins(
                fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.w600)),
          )).toList()),
          const SizedBox(height: 14),
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Harga / sesi', style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textLt(context))),
              Text(formattedPrice, style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tealDk)),
            ]),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: available ? onBook : null,
              icon: const Icon(Icons.video_call_outlined, size: 16),
              label: const Text('Booking Sesi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── Booking Sheet ─────────────────────────────────────────────
class _BookingSheet extends StatefulWidget {
  final Map<String, dynamic> psych;
  const _BookingSheet({required this.psych});
  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  String _sessionType = 'video';
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _loading = false;

  final _times = ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '19:00', '20:00'];

  Future<void> _book() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal dan waktu terlebih dahulu')));
      return;
    }

    setState(() => _loading = true);
    final price = widget.psych['session_price'] as int;
    final user = await AuthService.getUserProfile();
    if (user == null) return;

    final result = await PaymentService.createPayment(
      planId: 'session',
      userFullName: user.fullName,
      userEmail: user.email,
      userPhone: user.phone ?? '08100000000',
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pop(context);
      await PaymentService.openPaymentPage(result.paymentUrl!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Gagal booking'), backgroundColor: AppTheme.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.psych['full_name'] as String? ?? '';
    final price = widget.psych['session_price'] as int? ?? 0;
    final platform = price * 20 ~/ 100;
    final psychFee = price - platform;
    final formattedPrice = 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 40, height: 4,
          decoration: BoxDecoration(color: AppTheme.textLt(context), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text('Booking Sesi Konsultasi', style: Theme.of(context).textTheme.headlineMedium),
        Text('dengan $name', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.primary)),
        const SizedBox(height: 20),

        // Session type
        Text('Tipe Sesi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.text(context))),
        const SizedBox(height: 10),
        Row(children: [
          for (final type in [('video', '📹 Video Call'), ('voice', '📞 Voice Call'), ('chat', '💬 Chat')])
            Expanded(child: GestureDetector(
              onTap: () => setState(() => _sessionType = type.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(right: type == ('chat', '💬 Chat') ? 0 : 8),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _sessionType == type.$1 ? AppTheme.primary.withOpacity(0.12) : AppTheme.bg(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _sessionType == type.$1 ? AppTheme.primary : AppTheme.divider(context)),
                ),
                child: Center(child: Text(type.$2, style: GoogleFonts.poppins(
                    fontSize: 11.5, fontWeight: FontWeight.w600,
                    color: _sessionType == type.$1 ? AppTheme.primary : AppTheme.textMed(context)))),
              ),
            )),
        ]),

        const SizedBox(height: 18),
        // Date
        Text('Tanggal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.text(context))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now().add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.bg(context), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider(context)),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: AppTheme.primary),
              const SizedBox(width: 10),
              Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Pilih tanggal',
                style: GoogleFonts.poppins(fontSize: 14,
                    color: _selectedDate != null ? AppTheme.text(context) : AppTheme.textLt(context))),
            ]),
          ),
        ),

        const SizedBox(height: 14),
        Text('Waktu', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.text(context))),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _times.map((t) => GestureDetector(
          onTap: () => setState(() => _selectedTime = t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedTime == t ? AppTheme.primary : AppTheme.bg(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _selectedTime == t ? AppTheme.primary : AppTheme.divider(context)),
            ),
            child: Text(t, style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: _selectedTime == t ? Colors.white : AppTheme.textMed(context))),
          ),
        )).toList()),

        const SizedBox(height: 20),
        // Price breakdown
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.bg(context), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider(context)),
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Biaya sesi (60 menit)', style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMed(context))),
              Text(formattedPrice, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text(context))),
            ]),
            const Divider(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total Bayar', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text(context))),
              Text(formattedPrice, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _book,
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Bayar & Booking Sekarang'),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: Text('Pembayaran aman via Midtrans',
            style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textLt(context)))),
      ])),
    );
  }
}
