// lib/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  static final _sb = Supabase.instance.client;

  // ==========================
  // CURRENT USER
  // ==========================

  static User? get currentUser => _sb.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static String? get userId => currentUser?.id;

  static Stream<AuthState> get authStateChanges =>
      _sb.auth.onAuthStateChange;

  // ==========================
  // REGISTER
  // ==========================

  static Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String avatarEmoji = '😊',
  }) async {
    try {
      print("REGISTER EMAIL = $email");

      final response = await _sb.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'avatar_emoji': avatarEmoji,
        },
      );

      print("REGISTER USER = ${response.user?.id}");

      if (response.user == null) {
        return AuthResult.error(
          'Pendaftaran gagal. User tidak dibuat.',
        );
      }

      await _createUserProfile(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        avatarEmoji: avatarEmoji,
      );

      return AuthResult.success(
        response.user!,
        message: 'Pendaftaran berhasil',
      );
    } on AuthException catch (e) {
      print("AUTH ERROR = ${e.message}");

      return AuthResult.error(e.message);
    } catch (e) {
      print("SUPABASE ERROR = $e");

      return AuthResult.error(e.toString());
    }
  }

  // ==========================
  // LOGIN
  // ==========================

  static Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print("LOGIN EMAIL = $email");

      final response = await _sb.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print("LOGIN USER = ${response.user?.id}");

      if (response.user == null) {
        return AuthResult.error('Login gagal');
      }

      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      print("LOGIN AUTH ERROR = ${e.message}");

      return AuthResult.error(e.message);
    } catch (e) {
      print("LOGIN ERROR = $e");

      return AuthResult.error(e.toString());
    }
  }

  // ==========================
  // GOOGLE LOGIN
  // ==========================

  static Future<AuthResult> signInWithGoogle() async {
    try {
      await _sb.auth.signInWithOAuth(
        OAuthProvider.google,
      );

      final user = _sb.auth.currentUser;

      if (user == null) {
        return AuthResult.error(
          'Google Sign In dibatalkan',
        );
      }

      await _upsertUserFromOAuth(user);

      return AuthResult.success(user);
    } on AuthException catch (e) {
      print("GOOGLE ERROR = ${e.message}");

      return AuthResult.error(e.message);
    } catch (e) {
      print("GOOGLE ERROR = $e");

      return AuthResult.error(e.toString());
    }
  }

  // ==========================
  // RESET PASSWORD
  // ==========================

  static Future<AuthResult> resetPassword(
    String email,
  ) async {
    try {
      await _sb.auth.resetPasswordForEmail(email);

      return AuthResult.success(
        null,
        message: 'Link reset password telah dikirim',
      );
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    }
  }

  static Future<AuthResult> updatePassword(
    String newPassword,
  ) async {
    try {
      await _sb.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return AuthResult.success(
        null,
        message: 'Password berhasil diperbarui',
      );
    } on AuthException catch (e) {
      return AuthResult.error(e.message);
    }
  }

  // ==========================
  // LOGOUT
  // ==========================

  static Future<void> signOut() async {
    await _sb.auth.signOut();
  }

  // ==========================
  // USER PROFILE
  // ==========================

  static Future<UserModel?> getUserProfile() async {
    try {
      if (userId == null) return null;

      final data = await _sb
          .from('users')
          .select()
          .eq('id', userId!)
          .maybeSingle();

      if (data == null) {
        // If the user row doesn't exist yet, avoid crashing with PGRST116.
        return null;
      }

      return UserModel.fromJson(data);


    } catch (e) {
      print("GET USER ERROR = $e");
      return null;
    }
  }

  static Future<bool> updateUserProfile(
    Map<String, dynamic> updates,
  ) async {
    try {
      if (userId == null) return false;

      await _sb
          .from('users')
          .update(updates)
          .eq('id', userId!);

      return true;
    } catch (e) {
      print("UPDATE PROFILE ERROR = $e");
      return false;
    }
  }

  // ==========================
  // CREATE PROFILE
  // ==========================

  static Future<void> _createUserProfile({
    required String id,
    required String email,
    required String fullName,
    required String avatarEmoji,
  }) async {
    try {
      await _sb.from('users').upsert({
        'id': id,
        'email': email,
        'full_name': fullName,
        'avatar_emoji': avatarEmoji,
        'plan': 'free',
        'onboarded': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      print("USER PROFILE CREATED");
    } catch (e) {
      print("CREATE PROFILE ERROR = $e");
    }
  }

  // ==========================
  // OAUTH PROFILE
  // ==========================

  static Future<void> _upsertUserFromOAuth(
    User user,
  ) async {
    try {
      final existing = await _sb
          .from('users')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existing == null) {
        await _sb.from('users').insert({
          'id': user.id,
          'email': user.email,
          'full_name':
              user.userMetadata?['full_name'] ??
                  user.email?.split('@').first ??
                  'Pengguna',
          'avatar_url':
              user.userMetadata?['avatar_url'],
          'avatar_emoji': '😊',
          'plan': 'free',
          'onboarded': false,
          'created_at':
              DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print("UPSERT OAUTH ERROR = $e");
    }
  }
}

// ==========================
// AUTH RESULT
// ==========================

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;
  final String? message;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
    this.message,
  });

  factory AuthResult.success(
    User? user, {
    String? message,
  }) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
    );
  }

  factory AuthResult.error(
    String error,
  ) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}

