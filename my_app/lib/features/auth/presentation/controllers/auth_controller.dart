import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/env.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

class AuthController {
  final SupabaseClient _supabase;

  AuthController({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      debugPrint('Signing in with email: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('Sign in successful! User: ${response.user?.email}');
      return response;
    } catch (e, stack) {
      debugPrint('Exception during sign in: $e');
      debugPrint('Stacktrace: $stack');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      debugPrint('Signing up with email: $email');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      debugPrint('Sign up successful! User: ${response.user?.email}');
      return response;
    } catch (e, stack) {
      debugPrint('Exception during sign up: $e');
      debugPrint('Stacktrace: $stack');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _supabase.auth.signOut();
  }

  /// Sign in with Google using native plugin
  Future<bool> signInWithGoogle() async {
    try {
      debugPrint('Starting native Google sign in...');
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: Env.googleAuthWebClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Google sign in aborted by user');
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      debugPrint('Google sign in successful! User: ${response.user?.email}');
      return true;
    } catch (e, stack) {
      debugPrint('Exception during native Google sign in: $e');
      debugPrint('Stacktrace: $stack');
      rethrow;
    }
  }

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Listen to auth state changes
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;
}
