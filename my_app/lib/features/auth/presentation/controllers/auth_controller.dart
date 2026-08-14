import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/env.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

abstract interface class GoogleAuthClient {
  Future<GoogleSignInAuthentication?> authenticate();
  Future<void> signOut();
}

class NativeGoogleAuthClient implements GoogleAuthClient {
  NativeGoogleAuthClient({GoogleSignIn? googleSignIn})
    : _googleSignIn =
          googleSignIn ??
          GoogleSignIn(serverClientId: Env.googleAuthWebClientId);

  final GoogleSignIn _googleSignIn;

  @override
  Future<GoogleSignInAuthentication?> authenticate() async {
    final user = await _googleSignIn.signIn();
    return user?.authentication;
  }

  @override
  Future<void> signOut() => _googleSignIn.signOut();
}

class AuthController {
  AuthController({SupabaseClient? supabase, GoogleAuthClient? googleAuthClient})
    : _supabase = supabase ?? Supabase.instance.client,
      _googleAuthClient = googleAuthClient ?? NativeGoogleAuthClient();

  final SupabaseClient _supabase;
  final GoogleAuthClient _googleAuthClient;

  Future<AuthResponse> signInWithEmail(String email, String password) =>
      _supabase.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUpWithEmail(String email, String password) =>
      _supabase.auth.signUp(email: email, password: password);

  Future<void> signOut() async {
    try {
      await _googleAuthClient.signOut();
    } on Exception {
      // Supabase sign-out must still run if no native Google session exists.
    }
    await _supabase.auth.signOut();
  }

  Future<bool> signInWithGoogle() async {
    final authentication = await _googleAuthClient.authenticate();
    if (authentication == null) return false;

    final idToken = authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const FormatException('Google authentication returned no ID token');
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authentication.accessToken,
    );
    return true;
  }

  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;
}
