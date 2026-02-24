import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/splash_view.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'viewmodels/image_generation_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Supabase
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
    return ProviderScope(
      overrides: [
        // Override des providers avec les instances réelles
        authServiceProvider.overrideWith((ref) {
          final supabase = Supabase.instance.client;
          final googleSignIn = GoogleSignIn(
            clientId: AppConstants.googleClientId,
            scopes: ['email', 'profile'],
          );
          return AuthService(supabase, googleSignIn);
        }),
        supabaseServiceProvider.overrideWith((ref) {
          return SupabaseService();
        }),
        currentUserIdProvider.overrideWith((ref) {
          return Supabase.instance.client.auth.currentUser?.id;
        }),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashView(),
      ),
    );
  }
}

// Provider pour Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider pour Google Sign In
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    clientId: AppConstants.googleClientId,
    scopes: ['email', 'profile'],
  );
});
