import '../utils/logger.dart';

class SupabaseService {
  final _logger = AppLogger('SupabaseService');

  SupabaseService();

  // Mock de toutes les méthodes
  Future<dynamic> saveMessage(message) async {
    _logger.info('Mock: Message saved');
    return message;
  }

  Future<List<dynamic>> getUserMessages(userId, {mode, limit, before}) async {
    return [];
  }

  Future<List<dynamic>> getRecentMessages(userId, {count = 20}) async {
    return [];
  }

  Future<void> deleteMessage(messageId) async {
    _logger.info('Mock: Message deleted');
  }

  Future<void> deleteAllUserMessages(userId) async {
    _logger.info('Mock: All messages deleted');
  }

  Future<dynamic> saveProject(project) async {
    return project;
  }

  Future<List<dynamic>> getUserProjects(userId) async {
    return [];
  }

  Future<void> deleteProject(projectId) async {
    _logger.info('Mock: Project deleted');
  }

  Future<dynamic> saveGeneratedImage(image) async {
    return image;
  }

  Future<List<dynamic>> getUserImages(userId) async {
    return [];
  }

  Future<void> deleteImage(imageId) async {
    _logger.info('Mock: Image deleted');
  }

  Future<dynamic> getUserById(userId) async {
    return null;
  }

  Future<dynamic> updateUser(user) async {
    return user;
  }

  Future<int> cleanupOldMessages(days) async {
    return 0;
  }

  Future<void> compactUserData(userId) async {}

  Future<Map<String, dynamic>> getUsageStats(userId) async {
    return {
      'totalMessages': 0,
      'askMessages': 0,
      'agentMessages': 0,
      'totalProjects': 0,
      'totalImages': 0,
      'lastActivity': null,
    };
  }
}
