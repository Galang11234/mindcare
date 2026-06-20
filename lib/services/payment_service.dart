// lib/services/payment_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_model.dart';
import 'auth_service.dart';

class PaymentService {
  static final _sb = Supabase.instance.client;
  
  // Variabel penampung jika testing tanpa login atau data user gagal dimuat
  static bool _demoGuestPremium = false; 

  // ─────────────────────────────────────────────────────────────
  // PAKET HARGA
  // ─────────────────────────────────────────────────────────────
  static const Map<String, PricePlan> plans = {
    'premium_monthly': PricePlan(
      id: 'premium_monthly',
      name: 'Premium Monthly',
      description: 'Akses penuh semua fitur MindCare selama 1 bulan',
      price: 29900,
      period: '1 Bulan',
      features: [
        'AI Chatbot Claude tanpa batas',
        'Statistik & grafik advanced',
        'Export laporan PDF',
        'Semua latihan relaksasi',
        'Artikel premium eksklusif',
        'Hapus semua iklan',
        'Prioritas dukungan',
      ],
    ),
    'premium_annual': PricePlan(
      id: 'premium_annual',
      name: 'Premium Tahunan',
      description: 'Hemat 40%! Akses penuh selama 12 bulan',
      price: 215000,
      period: '12 Bulan',
      originalPrice: 358800,
      discountPercent: 40,
      features: [
        'Semua fitur Premium Monthly',
        'Hemat Rp143.800 per tahun',
        'Priority customer support',
        'Early access fitur baru',
        'Badge Premium Annual eksklusif',
      ],
      isBestValue: true,
    ),
    'institution_campus': PricePlan(
      id: 'institution_campus',
      name: 'Paket Kampus',
      description: 'Untuk universitas & perguruan tinggi',
      price: 5000000,
      period: '12 Bulan',
      features: [
        'Akun unlimited mahasiswa',
        'Dashboard admin institusi',
        'Laporan kesehatan mental kolektif',
        'Data anonim & PDPA compliant',
        'Training tim konselor',
        'Dedicated account manager',
        'Integrasi SSO kampus',
      ],
    ),
    'institution_corporate': PricePlan(
      id: 'institution_corporate',
      name: 'Paket Korporat',
      description: 'Untuk perusahaan & organisasi',
      price: 15000000,
      period: '12 Bulan',
      features: [
        'Employee Assistance Program (EAP)',
        'Akun unlimited karyawan',
        'Laporan HR (anonim agregat)',
        'Konsultasi psikolog (program)',
        'Data anonim & PDPA compliant',
        'Dedicated account manager',
        'Integrasi SSO perusahaan',
      ],
    ),
    'session': PricePlan(
      id: 'session',
      name: 'Sesi Konsultasi Psikolog',
      description: 'Pembayaran booking sesi konsultasi psikolog',
      price: 150000,
      period: '1 Sesi',
      features: ['Booking sesi', 'Akses sesi konsultasi sesuai jadwal'],
    ),
  };

  // ─────────────────────────────────────────────────────────────
  // CREATE PAYMENT — FULL SIMULATION (KEBAL ERROR)
  // ─────────────────────────────────────────────────────────────
  static Future<PaymentResult> createPayment({
    required String planId,
    required String userFullName,
    required String userEmail,
    required String userPhone,
  }) async {
    final plan = plans[planId];
    if (plan == null) {
      return PaymentResult.error('Plan tidak ditemukan');
    }

    try {
      // Simulasi delay jaringan 2 detik agar terasa natural
      await Future.delayed(const Duration(seconds: 2));

      final orderId = 'DEMO-${DateTime.now().millisecondsSinceEpoch}';
      final uid = AuthService.userId;

      // JIKA BELUM LOGIN: Bypass Supabase, update UI lokal saja
      if (uid == null) {
        if (planId != 'session') _demoGuestPremium = true;
        return PaymentResult.success(orderId: orderId, amount: plan.price);
      }

      // JIKA SUDAH LOGIN: Simpan ke Supabase
      final paymentData = {
        'user_id': uid,
        'order_id': orderId,
        'amount': plan.price,
        'currency': 'IDR',
        'payment_type': planId,
        'status': 'paid',
        'description': plan.description,
        'paid_at': DateTime.now().toIso8601String(),
      };

      final insertedPayment = await _sb.from('payments').insert(paymentData).select().single();

      if (planId != 'session') {
        await _activateSubscription(insertedPayment);
      }

      return PaymentResult.success(orderId: orderId, amount: plan.price);
    } catch (e) {
      return PaymentResult.error(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ACTIVATE SUBSCRIPTION
  // ─────────────────────────────────────────────────────────────
  static Future<void> _activateSubscription(Map<String, dynamic> payment) async {
    final uid = payment['user_id'];
    final paymentType = payment['payment_type'] as String;

    String planName;
    DateTime expiresAt;

    if (paymentType.contains('institution')) {
      planName = 'institution';
      expiresAt = DateTime.now().add(const Duration(days: 365));
    } else {
      planName = 'premium';
      if (paymentType == 'premium_annual') {
        expiresAt = DateTime.now().add(const Duration(days: 365));
      } else {
        expiresAt = DateTime.now().add(const Duration(days: 30));
      }
    }

    await _sb.from('users').update({
      'plan': planName,
      'plan_expires_at': expiresAt.toIso8601String(),
    }).eq('id', uid);

    try {
      await _sb.from('subscriptions').insert({
        'user_id': uid,
        'plan': paymentType,
        'status': 'active',
        'amount': payment['amount'],
        'payment_id': payment['id'],
        'starts_at': DateTime.now().toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      });
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────
  // CHECK PREMIUM ACCESS
  // ─────────────────────────────────────────────────────────────
  static Future<bool> isPremium() async {
    final uid = AuthService.userId;
    // Gunakan variabel lokal jika belum login
    if (uid == null) return _demoGuestPremium; 
    
    try {
      final data = await _sb
          .from('users')
          .select('plan, plan_expires_at')
          .eq('id', uid)
          .single();
      final plan = data['plan'] as String?;
      final expiresAtStr = data['plan_expires_at'] as String?;
      
      if (plan == 'free' || plan == null) return false;
      if (expiresAtStr == null) return true; 
      
      return DateTime.parse(expiresAtStr).isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // GET PAYMENT HISTORY
  // ─────────────────────────────────────────────────────────────
  static Future<List<PaymentModel>> getPaymentHistory() async {
    final uid = AuthService.userId;
    if (uid == null) return [];
    try {
      final data = await _sb
          .from('payments')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(20);
      return (data as List).map((d) => PaymentModel.fromJson(d)).toList();
    } catch (_) {
      return [];
    }
  }
}

// ── Models ────────────────────────────────────────────────────
class PaymentResult {
  final bool isSuccess;
  final String? orderId, error;
  final int? amount;
  
  PaymentResult._({required this.isSuccess, this.orderId, this.error, this.amount});
  
  factory PaymentResult.success({required String orderId, required int amount}) =>
      PaymentResult._(isSuccess: true, orderId: orderId, amount: amount);
      
  factory PaymentResult.error(String error) =>
      PaymentResult._(isSuccess: false, error: error);
}

class PricePlan {
  final String id, name, description, period;
  final int price;
  final int? originalPrice, discountPercent;
  final List<String> features;
  final bool isBestValue;
  const PricePlan({
    required this.id, required this.name, required this.description,
    required this.price, required this.period, required this.features,
    this.originalPrice, this.discountPercent, this.isBestValue = false,
  });

  String get formattedPrice => 'Rp ${_fmt(price)}';
  String get formattedOriginal => originalPrice != null ? 'Rp ${_fmt(originalPrice!)}' : '';
  static String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}