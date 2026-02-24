import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/splash_view.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const SplashView(),
    );
  }
}

// Providers
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(Supabase.instance.client);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = Supabase.instance.client;
  final googleSignIn = GoogleSignIn(
    clientId: AppConstants.googleClientId,
    scopes: ['email', 'profile'],
  );
  return AuthService(supabase, googleSignIn);
});

final currentUserIdProvider = Provider<String?>((ref) {
  return Supabase.instance.client.auth.currentUser?.id;
});
