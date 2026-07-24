import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  static String get googleAuthWebClientId => dotenv.env['GOOGLE_AUTH_WEB_CLIENT_ID'] ?? '';
  static String get googleAuthAndroidClientId => dotenv.env['GOOGLE_AUTH_ANDROID_CLIENT_ID'] ?? '';
  static String get googleAuthIosClientId => dotenv.env['GOOGLE_AUTH_IOS_CLIENT_ID'] ?? '';
}
