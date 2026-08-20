abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const googleAuthWebClientId = String.fromEnvironment(
    'GOOGLE_AUTH_WEB_CLIENT_ID',
  );
  static const googleAuthAndroidClientId = String.fromEnvironment(
    'GOOGLE_AUTH_ANDROID_CLIENT_ID',
  );
  static const googleAuthIosClientId = String.fromEnvironment(
    'GOOGLE_AUTH_IOS_CLIENT_ID',
  );
  static const subscriptionPortalUrl = String.fromEnvironment(
    'SUBSCRIPTION_PORTAL_URL',
    defaultValue: 'https://song-list-admin-side.vercel.app/user-login',
  );

  static List<String> get missingRequiredKeys {
    const requiredValues = {
      'SUPABASE_URL': supabaseUrl,
      'SUPABASE_ANON_KEY': supabaseAnonKey,
      'GOOGLE_AUTH_WEB_CLIENT_ID': googleAuthWebClientId,
    };
    return requiredValues.entries
        .where((entry) => entry.value.trim().isEmpty)
        .map((entry) => entry.key)
        .toList(growable: false);
  }
}
