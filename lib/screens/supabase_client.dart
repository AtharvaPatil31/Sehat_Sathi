import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientManager {
  static const String supabaseUrl = 'https://mlzhsefjtzoncvstgnxr.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1semhzZWZqdHpvbmN2c3RnbnhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyMDA3OTIsImV4cCI6MjA3Mzc3Njc5Mn0.vUTQTx7K56Hnwiy1iGGlUPwCZv2D8KttIIHOfgj09PU';

  static late final SupabaseClient client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    client = Supabase.instance.client;
  }
}
