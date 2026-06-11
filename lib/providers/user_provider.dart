import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';

class UserProvider extends ChangeNotifier {
  final _sb = Supabase.instance.client;

  UserModel? _user;
  bool _isPremium = false;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isPremium => _isPremium;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  String get displayName => _user?.fullName ?? 'Pengguna';
  String get avatarEmoji => _user?.avatarEmoji ?? '😊';
  String get plan => _user?.plan ?? 'free';

  // ── Init / Load ─────────────────────────────────────────────
  Future<void> initialize() async {
    if (AuthService.userId == null) return;
    _loading = true;
    notifyListeners();
    try {
      _user = await AuthService.getUserProfile();
      _isPremium = await PaymentService.isPremium();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  // ── Update Profile ───────────────────────────────────────────
  Future<bool> updateProfile({
    String? fullName,
    String? avatarEmoji,
    String? phone,
    String? city,
    String? occupation,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarEmoji != null) updates['avatar_emoji'] = avatarEmoji;
    if (phone != null) updates['phone'] = phone;
    if (city != null) updates['city'] = city;
    if (occupation != null) updates['occupation'] = occupation;

    final ok = await AuthService.updateUserProfile(updates);
    if (ok) {
      _user = await AuthService.getUserProfile();
      notifyListeners();
    }
    return ok;
  }

  // ── Refresh Premium Status ───────────────────────────────────
  Future<void> refreshPremiumStatus() async {
    _isPremium = await PaymentService.isPremium();
    _user = await AuthService.getUserProfile();
    notifyListeners();
  }

  // ── Sign Out ─────────────────────────────────────────────────
  Future<void> signOut() async {
    await AuthService.signOut();
    _user = null;
    _isPremium = false;
    notifyListeners();
  }

  // ── Premium Gate Helper ──────────────────────────────────────
  /// Tampilkan dialog upgrade jika bukan premium
  bool requirePremium(BuildContext context, {String? feature}) {
    if (_isPremium) return true;
    _showUpgradeDialog(context, feature: feature);
    return false;
  }

  void _showUpgradeDialog(BuildContext context, {String? feature}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('✨', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text('Fitur Premium', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            feature != null
                ? '$feature hanya tersedia untuk pengguna Premium.'
                : 'Fitur ini hanya tersedia untuk pengguna Premium MindCare.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/subscription');
              },
              child: const Text('Upgrade Sekarang ✨'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Nanti Saja'),
          ),
        ]),
      ),
    );
  }
}