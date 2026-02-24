import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

// Provider pour le AuthViewModel
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthViewModel(authService);
});

// Provider pour le service d'authentification
final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('Doit être override dans main.dart');
});

// État d'authentification
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  AuthState clearError() {
    return AuthState(
      user: user,
      isLoading: isLoading,
      error: null,
      isAuthenticated: isAuthenticated,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService;
  final _logger = AppLogger('AuthViewModel');

  AuthViewModel(this._authService) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    // Vérifier s'il y a une session existante
    final hasSession = await _authService.restoreSession();
    if (hasSession) {
      state = state.copyWith(
        user: _authService.currentUser,
        isAuthenticated: true,
      );
    }
  }

  // Connexion avec Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true);

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
        );
        _logger.info('User signed in: ${user.email}');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Échec de la connexion',
        );
      }
    } catch (e) {
      _logger.error('Sign in error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);

      await _authService.signOut();

      state = const AuthState();
      _logger.info('User signed out');
    } catch (e) {
      _logger.error('Sign out error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Rafraîchir la session
  Future<void> refreshSession() async {
    try {
      await _authService.refreshSession();
      _logger.info('Session refreshed');
    } catch (e) {
      _logger.error('Session refresh error: $e');
    }
  }

  // Effacer l'erreur
  void clearError() {
    state = state.clearError();
  }

  // Mettre à jour les préférences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      await _authService.updatePreferences(preferences);
      state = state.copyWith(user: _authService.currentUser);
    } catch (e) {
      _logger.error('Update preferences error: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  // Obtenir l'ID utilisateur courant
  String? get currentUserId => _authService.currentUserId;

  // Vérifier si authentifié
  bool get isAuthenticated => _authService.isAuthenticated;
}
