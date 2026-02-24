import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';

class AuthService {
  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;
  final _logger = AppLogger('AuthService');

  UserModel? _currentUser;
  StreamSubscription<AuthState>? _authStateSubscription;

  AuthService(this._supabase, this._googleSignIn) {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    _authStateSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      _logger.info('Auth state changed: $event');

      if (event == AuthChangeEvent.signedIn && session != null) {
        _loadUserData(session.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .filter('id', 'eq', userId)
          .single();

      _currentUser = UserModel.fromJson(response);
      _logger.info('User data loaded: ${_currentUser?.email}');
    } catch (e) {
      _logger.error('Error loading user data: $e');
    }
  }

  // Connexion avec Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      _logger.info('Starting Google sign in...');

      // Déconnexion préalable pour éviter les conflits
      await _googleSignIn.signOut();

      // Lancer le flux de connexion Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.warning('Google sign in cancelled by user');
        throw Exception('Connexion annulée par l\'utilisateur');
      }

      _logger.info('Google user: ${googleUser.email}');

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Impossible d\'obtenir les tokens d\'authentification');
      }

      // Connexion à Supabase avec le token Google
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user == null) {
        throw Exception('Échec de la connexion Supabase');
      }

      _logger.info('Supabase auth successful: ${response.user!.email}');

      // Créer ou mettre à jour l'utilisateur dans la base de données
      await _createOrUpdateUser(googleUser, response.user!.id);

      // Charger les données utilisateur
      await _loadUserData(response.user!.id);

      return _currentUser;
    } on Exception catch (e) {
      _logger.error('Google sign in error: $e');
      rethrow;
    }
  }

  Future<void> _createOrUpdateUser(
      GoogleSignInAccount googleUser, String userId) async {
    try {
      // Vérifier si l'utilisateur existe déjà
      final existingUser = await _supabase
          .from('users')
          .select()
          .filter('id', 'eq', userId)
          .maybeSingle();

      if (existingUser == null) {
        // Créer un nouvel utilisateur
        await _supabase.from('users').insert({
          'id': userId,
          'email': googleUser.email,
          'name': googleUser.displayName,
          'photo_url': googleUser.photoUrl,
          'created_at': DateTime.now().toIso8601String(),
          'preferences': {},
        });
        _logger.info('New user created: ${googleUser.email}');
      } else {
        // Mettre à jour les informations
        await _supabase.from('users').update({
          'name': googleUser.displayName,
          'photo_url': googleUser.photoUrl,
        }).filter('id', 'eq', userId);
        _logger.info('User updated: ${googleUser.email}');
      }
    } catch (e) {
      _logger.error('Error creating/updating user: $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      _logger.info('Signing out...');
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
      _currentUser = null;
      _logger.info('Sign out successful');
    } catch (e) {
      _logger.error('Sign out error: $e');
      rethrow;
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  // Obtenir l'utilisateur courant
  UserModel? get currentUser => _currentUser;

  // Obtenir l'ID de l'utilisateur courant
  String? get currentUserId => _supabase.auth.currentUser?.id;

  // Obtenir la session courante
  Session? get currentSession => _supabase.auth.currentSession;

  // Stream d'état d'authentification
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Rafraîchir la session
  Future<void> refreshSession() async {
    try {
      await _supabase.auth.refreshSession();
      _logger.info('Session refreshed');
    } catch (e) {
      _logger.error('Session refresh error: $e');
      rethrow;
    }
  }

  // Vérifier et restaurer la session
  Future<bool> restoreSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null && !session.isExpired) {
        await _loadUserData(session.user.id);
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('Session restore error: $e');
      return false;
    }
  }

  // Mettre à jour les préférences utilisateur
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('Utilisateur non connecté');

      await _supabase.from('users').update({
        'preferences': preferences,
      }).filter('id', 'eq', userId);

      // Recharger les données
      await _loadUserData(userId);
    } catch (e) {
      _logger.error('Error updating preferences: $e');
      rethrow;
    }
  }

  void dispose() {
    _authStateSubscription?.cancel();
  }
}
