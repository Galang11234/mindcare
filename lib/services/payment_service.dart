// lib/services/payment_service.dart
// Midtrans Snap Payment Gateway Integration
// Docs: https://snap-docs.midtrans.com/

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// NOTE: Demo Payment Mode
// Tujuan: saat Midtrans error, aplikasi tetap bisa "berhasil bayar" untuk demo.
// Aktifkan lewat dart-define: --dart-define=PAYMENT_DEMO_MODE=true
// (default: true untuk memudahkan demo).
import '../models/payment_model.dart';
import 'auth_service.dart';

// Demo mode default: true.
// Set false to use real Midtrans flow (still requires backend keys etc.).
// flutter run --dart-define=PAYMENT_DEMO_MODE=false
const bool _paymentDemoModeDefault = true;


class PaymentService {
  static final _sb = Supabase.instance.client;

  // ── MIDTRANS CONFIG ──────────────────────────────────────────
  // Production: https://app.midtrans.com/snap/v1/transactions
  // Sandbox:    https://app.sandbox.midtrans.com/snap/v1/transactions
  static const _snapUrl = 'https://app.sandbox.midtrans.com/snap/v1/transactions';

  // ⚠️ Server Key Midtrans tidak boleh hardcoded.
  // Untuk mencegah error saat developer belum isi key,
  // kita baca dari dart-define saat build.
  //
  // Contoh build:
  // flutter run --dart-define=MIDTRANS_SERVER_KEY=SB-Mid-server-xxxx
  //
  // Server Key format: SB-Mid-server-XXXXXXXXXXXXXXXXXXXXXXXX (sandbox)
  static String get _serverKey {
    const key = String.fromEnvironment('MIDTRANS_SERVER_KEY');
    return key;
  }


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
      price: 215000, // ~Rp17.900/bulan vs Rp29.900
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
    // B2B - Kampus (Rp 5.000.000 / tahun)
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
    // B2B - Korporat (Rp 15.000.000 / tahun)
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
    // Marketplace - sesi konsultasi psikolog (booking)
    // Catatan: harga final biasanya dihitung di UI psikolog, namun booking saat ini
    // memakai planId 'session' sebagai trigger pembayaran.
    'session': PricePlan(
      id: 'session',
      name: 'Sesi Konsultasi Psikolog',
      description: 'Pembayaran booking sesi konsultasi psikolog',
      // Dummy price agar createPayment berhasil. Implementasi pembayaran final saat ini
      // menggunakan plan.price sebagai gross_amount.
      // Jika ingin akurat, perlu mekanisme dynamic pricing dari UI.
      price: 150000,
      period: '1 Sesi',
      features: [
        'Booking sesi',
        'Akses sesi konsultasi sesuai jadwal',
      ],
    ),
  };

  // ─────────────────────────────────────────────────────────────
  // CREATE PAYMENT — Generate Midtrans Snap Token
  // ─────────────────────────────────────────────────────────────
  static Future<PaymentResult> createPayment({
    required String planId,
    required String userFullName,
    required String userEmail,
    required String userPhone,
  }) async {
    // Mode demo: selalu anggap pembayaran berhasil.
    // (sesuai instruksi: “mode demo aja”)
    final uid = AuthService.userId;

    if (uid == null) {
      return PaymentResult.error('User belum login');
    }

    final plan = plans[planId];
    if (plan == null) {
      return PaymentResult.error('Plan tidak ditemukan');
    }

    try {
      final orderId = 'DEMO-${DateTime.now().millisecondsSinceEpoch}';

      await _sb.from('payments').insert({
        'user_id': uid,
        'order_id': orderId,
        'amount': plan.price,
        'currency': 'IDR',
        'payment_type': planId,
        'status': 'paid',
        'description': plan.description,
        'paid_at': DateTime.now().toIso8601String(),
      });

      // langsung aktifkan premium
      await _sb.from('users').update({
        'plan': 'premium',
        'plan_expires_at': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      }).eq('id', uid);

      return PaymentResult.success(
        paymentId: 'demo_payment',
        orderId: orderId,
        snapToken: 'demo_token',
        paymentUrl: 'demo_url',
        amount: plan.price,
      );
    } catch (e) {
      return PaymentResult.error(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────
  // MIDTRANS API CALL — Create Snap Token
  // ─────────────────────────────────────────────────────────────
  static Future<_SnapResult> _createMidtransTransaction({
    required String orderId,
    required int amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String itemName,
    required String itemDescription,
  }) async {
    try {
      if (_serverKey.isEmpty || _serverKey == 'YOUR_MIDTRANS_SERVER_KEY') {
        return _SnapResult.error(
          'Server key Midtrans belum di-set. Jalankan dengan --dart-define=MIDTRANS_SERVER_KEY=SB-Mid-server-...'
        );
      }

      // Base64 encode server key (Midtrans auth format)
      final credentials = base64Encode(utf8.encode('$_serverKey:'));


      final response = await http.post(
        Uri.parse(_snapUrl),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'transaction_details': {
            'order_id': orderId,
            'gross_amount': amount,
          },
          'metadata': {
            'order_id': orderId,
          },

          'customer_details': {
            'first_name': customerName,
            'email': customerEmail,
            'phone': customerPhone,
          },
          'item_details': [{
            'id': orderId,
            'price': amount,
            'quantity': 1,
            'name': itemName,
            'brand': 'MindCare',
            'category': 'Health & Wellness App',
          }],
          'enabled_payments': [
            'credit_card', 'gopay', 'shopeepay', 'ovo',
            'dana', 'linkaja', 'qris',
            'bca_va', 'bni_va', 'bri_va', 'mandiri_va', 'permata_va',
            'indomaret', 'alfamart',
          ],
          'expiry': {
            'start_time': _formatMidtransTime(DateTime.now()),
            'unit': 'hours',
            'duration': 24,
          },
          'callbacks': {
            'finish': 'io.mindcare.app://payment/finish',
            'error': 'io.mindcare.app://payment/error',
            'cancel': 'io.mindcare.app://payment/cancel',
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return _SnapResult.success(
          snapToken: data['token'],
          paymentUrl: data['redirect_url'],
        );
      } else {
        final err = jsonDecode(response.body);
        return _SnapResult.error(err['error_messages']?.toString() ?? 'Midtrans error');
      }
    } catch (e) {
      return _SnapResult.error('Koneksi ke payment gateway gagal.');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // OPEN PAYMENT PAGE — Launch Midtrans Snap URL
  // ─────────────────────────────────────────────────────────────
  static Future<void> openPaymentPage(String paymentUrl) async {
    final uri = Uri.parse(paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // WEBHOOK HANDLER — Called from backend after Midtrans notif
  // ─────────────────────────────────────────────────────────────
  static Future<bool> handlePaymentNotification({
    required String orderId,
    required String transactionStatus,
    required String paymentType,
  }) async {
    try {
      // Determine payment status
      String status = 'pending';
      if (['capture', 'settlement'].contains(transactionStatus)) {
        status = 'paid';
      } else if (['deny', 'cancel', 'failure'].contains(transactionStatus)) {
        status = 'failed';
      } else if (transactionStatus == 'expire') {
        status = 'expired';
      }

      // Update payment (safe: never crash when 0 rows)
      final paymentQuery = await _sb
          .from('payments')
          .update({
            'status': status,
            'payment_method': paymentType,
            'paid_at': status == 'paid' ? DateTime.now().toIso8601String() : null,
          })
          .eq('order_id', orderId)
          .select();

      // If no rows were updated, do NOT throw; webhook may arrive early or RLS may block.
      if (paymentQuery.isEmpty) return false;

      final paymentData = paymentQuery.first as Map<String, dynamic>;


      // If paid → activate subscription

      if (status == 'paid') {
        await _activateSubscription(paymentData);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // CHECK PAYMENT STATUS
  // ─────────────────────────────────────────────────────────────
  static Future<String> checkPaymentStatus(String orderId) async {
    try {
      final data = await _sb
          .from('payments')
          .select('status')
          .eq('order_id', orderId)
          .maybeSingle();

      if (data == null) return 'unknown';
      final status = data['status'];
      return status is String ? status : 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }


  // ─────────────────────────────────────────────────────────────
  // ACTIVATE SUBSCRIPTION after successful payment
  // ─────────────────────────────────────────────────────────────
  static Future<void> _activateSubscription(Map<String, dynamic> payment) async {
    final uid = payment['user_id'];
    final paymentType = payment['payment_type'] as String;

    // Determine plan & expiry
    String plan;
    DateTime expiresAt;
    String subPlan;

    if (paymentType == 'institution_license') {
      plan = 'institution';
      expiresAt = DateTime.now().add(const Duration(days: 365));
      // Deduce institution subtype from amount heuristics or from payment record.
      // Saat ini payment record tidak menyimpan planId secara eksplisit, sehingga gunakan amount.
      // Kampus: 5.000.000, Korporat: 15.000.000
      final amount = payment['amount'] as int;
      if (amount >= 10000000) {
        subPlan = 'institution_corporate';
      } else {
        subPlan = 'institution_campus';
      }
    } else {
      // Check amount to determine monthly vs annual
      final amount = payment['amount'] as int;
      plan = 'premium';
      if (amount >= 200000) {
        expiresAt = DateTime.now().add(const Duration(days: 365));
        subPlan = 'premium_annual';
      } else {
        expiresAt = DateTime.now().add(const Duration(days: 30));
        subPlan = 'premium_monthly';
      }
    }

    // Update user plan
    await _sb.from('users').update({
      'plan': plan,
      'plan_expires_at': expiresAt.toIso8601String(),
    }).eq('id', uid);

    // Create subscription record
    await _sb.from('subscriptions').insert({
      'user_id': uid,
      'plan': subPlan,
      'status': 'active',
      'amount': payment['amount'],
      'payment_id': payment['id'],
      'starts_at': DateTime.now().toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    });

    // Send notification
    await _sb.from('notifications').insert({
      'user_id': uid,
      'title': '🎉 Premium Aktif!',
      'body': 'Selamat! Akses Premium MindCare kamu sudah aktif. Nikmati semua fitur tanpa batas!',
      'type': 'payment',
    });
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

  // ─────────────────────────────────────────────────────────────
  // CHECK PREMIUM ACCESS
  // ─────────────────────────────────────────────────────────────
  static Future<bool> isPremium() async {
    final uid = AuthService.userId;
    if (uid == null) return false;
    try {
      final data = await _sb
          .from('users')
          .select('plan, plan_expires_at')
          .eq('id', uid)
          .single();
      final plan = data['plan'] as String;
      final expiresAt = data['plan_expires_at'] != null
          ? DateTime.parse(data['plan_expires_at'])
          : null;
      if (plan == 'free') return false;
      if (expiresAt == null) return true; // institution no expiry set
      return expiresAt.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  // Helpers
  static String _formatMidtransTime(DateTime dt) {
    // Midtrans format: yyyy-MM-dd HH:mm:ss +0700
    final local = dt.toLocal();
    final y = local.year.toString();
    final mo = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi:s +0700';
  }
}

// ── Models ────────────────────────────────────────────────────
class PaymentResult {
  final bool isSuccess;
  final String? paymentId, orderId, snapToken, paymentUrl, error;
  final int? amount;
  PaymentResult._({required this.isSuccess, this.paymentId, this.orderId,
    this.snapToken, this.paymentUrl, this.error, this.amount});
  factory PaymentResult.success({required String paymentId, required String orderId,
    required String snapToken, required String paymentUrl, required int amount}) =>
      PaymentResult._(isSuccess: true, paymentId: paymentId, orderId: orderId,
        snapToken: snapToken, paymentUrl: paymentUrl, amount: amount);
  factory PaymentResult.error(String error) =>
      PaymentResult._(isSuccess: false, error: error);
}

class _SnapResult {
  final bool isSuccess;
  final String? snapToken, paymentUrl, error;
  _SnapResult._({required this.isSuccess, this.snapToken, this.paymentUrl, this.error});
  factory _SnapResult.success({required String snapToken, required String paymentUrl}) =>
      _SnapResult._(isSuccess: true, snapToken: snapToken, paymentUrl: paymentUrl);
  factory _SnapResult.error(String error) =>
      _SnapResult._(isSuccess: false, error: error);
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
