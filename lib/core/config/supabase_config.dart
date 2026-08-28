/// Supabase Configuration for FitX
class SupabaseConfig {
  /// Project URL and Publishable / Anon Key from Supabase Dashboard > Settings > API.
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xyxjipqioxoviwzfgcnx.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_dUDEsIUcQ31GABEuXW9fig_bpmKbC0w',
    ),
  );

  /// Backwards compatibility alias
  static String get anonKey => publishableKey;

  /// Helper to check if credentials have been configured
  static bool get isConfigured =>
      url.isNotEmpty &&
      publishableKey.isNotEmpty &&
      !url.contains('YOUR_PROJECT_ID') &&
      !publishableKey.contains('YOUR_ANON_PUBLIC_KEY');
}
