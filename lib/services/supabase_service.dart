import '../models/message_model.dart';
import '../models/project_model.dart';
import '../models/generated_image_model.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';

// Mock de SupabaseClient
class SupabaseClient {
  final auth = SupabaseAuth();
  final from = SupabaseFrom();
}

class SupabaseAuth {
  User? currentUser;
  Stream<AuthState> get onAuthStateChange => const Stream.empty();
  
  Future<void> signOut() async {}
  Future<void> refreshSession() async {}
  
  Future<AuthResponse> signInWithIdToken({
    required OAuthProvider provider,
    required String idToken,
    String? accessToken,
  }) async {
    return AuthResponse(
      user: User(id: 'mock-user-id'),
      session: Session(),
    );
  }
}

class SupabaseFrom {
  SupabaseQueryBuilder call(String table) => SupabaseQueryBuilder(table);
}

class SupabaseQueryBuilder {
  final String table;
  SupabaseQueryBuilder(this.table);
  
  Future<List<Map<String, dynamic>>> select() async => [];
  Future<Map<String, dynamic>?> maybeSingle() async => null;
  Future<Map<String, dynamic>> single() async => {};
  
  SupabaseQueryBuilder filter(String column, String operator, dynamic value) {
    return this;
  }
  
  SupabaseQueryBuilder eq(String column, dynamic value) {
    return this;
  }
  
  SupabaseQueryBuilder order(String column, {bool ascending = true}) {
    return this;
  }
  
  SupabaseQueryBuilder limit(int count) {
    return this;
  }
  
  Future<Map<String, dynamic>> insert(Map<String, dynamic> values) async => {};
  Future<Map<String, dynamic>> update(Map<String, dynamic> values) async => {};
  Future<void> delete() async {}
}

// Classes mock pour les types Supabase
class AuthState {}
class OAuthProvider {
  static const google = OAuthProvider._();
  const OAuthProvider._();
}

class AuthResponse {
  final User? user;
  final Session? session;
  AuthResponse({this.user, this.session});
}

class User {
  final String id;
  User({required this.id});
}

class Session {
  bool get isExpired => false;
  final user = User(id: 'mock-user-id');
}

// Service principal qui expose SupabaseClient
class SupabaseService {
  final SupabaseClient client;
  final _logger = AppLogger('SupabaseService');

  SupabaseService() : client = SupabaseClient();
}
