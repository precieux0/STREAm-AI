import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'views/splash_view.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase désactivé temporairement
  // await Supabase.initialize(
  //   url: AppConstants.supabaseUrl,
  //   anonKey: AppConstants.supabaseAnonKey,
  // );

  runApp(
    const ProviderScope(
      child: StreamAIApp(),
    ),
  );
}

class StreamAIApp extends StatelessWidget {
  const StreamAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashView(),
    );
  }
}

// Providers
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(); // Utilise le mock
});

final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  final googleSignIn = GoogleSignIn(
    clientId: AppConstants.googleClientId,
    scopes: ['email', 'profile'],
  );
  return AuthService(supabase, googleSignIn);
});

final currentUserIdProvider = Provider<String?>((ref) {
  return null; // Pas d'utilisateur connecté en mode mock
});
