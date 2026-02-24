import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';

class SupabaseService {
  final SupabaseClient _client;
  final _logger = AppLogger('SupabaseService');

  SupabaseService(this._client);

  // ==================== GESTION DES MESSAGES ====================

  // Sauvegarder un message
  Future<MessageModel> saveMessage(MessageModel message) async {
    try {
      final response = await _client
          .from('messages')
          .insert(message.toJson())
          .select()
          .single();

      _logger.info('Message saved: ${message.id}');
      return MessageModel.fromJson(response);
    } catch (e) {
      _logger.error('Error saving message: $e');
      rethrow;
    }
  }

  // Récupérer l'historique des messages d'un utilisateur
  Future<List<MessageModel>> getUserMessages(
    String userId, {
    String? mode,
    int limit = AppConstants.maxChatHistory,
    DateTime? before,
  }) async {
    try {
      var query = _client
          .from('messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      if (mode != null) {
        query = query.eq('mode', mode);
      }

      if (before != null) {
        query = query.lt('created_at', before.toIso8601String());
      }

      final response = await query;

      final messages = (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();

      _logger.info('Retrieved ${messages.length} messages for user $userId');
      return messages.reversed.toList();
    } catch (e) {
      _logger.error('Error getting user messages: $e');
      rethrow;
    }
  }

  // Récupérer les messages récents
  Future<List<MessageModel>> getRecentMessages(
    String userId, {
    int count = 20,
  }) async {
    return getUserMessages(userId, limit: count);
  }

  // Supprimer un message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _client.from('messages').delete().eq('id', messageId);
      _logger.info('Message deleted: $messageId');
    } catch (e) {
      _logger.error('Error deleting message: $e');
      rethrow;
    }
  }

  // Supprimer tous les messages d'un utilisateur
  Future<void> deleteAllUserMessages(String userId) async {
    try {
      await _client.from('messages').delete().eq('user_id', userId);
      _logger.info('All messages deleted for user: $userId');
    } catch (e) {
      _logger.error('Error deleting all user messages: $e');
      rethrow;
    }
  }

  // ==================== GESTION DES PROJETS ====================

  // Sauvegarder un projet
  Future<ProjectModel> saveProject(ProjectModel project) async {
    try {
      final response = await _client
          .from('projects')
          .insert(project.toJson())
          .select()
          .single();

      _logger.info('Project saved: ${project.id}');
      return ProjectModel.fromJson(response);
    } catch (e) {
      _logger.error('Error saving project: $e');
      rethrow;
    }
  }

  // Récupérer les projets d'un utilisateur
  Future<List<ProjectModel>> getUserProjects(String userId) async {
    try {
      final response = await _client
          .from('projects')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final projects = (response as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();

      _logger.info('Retrieved ${projects.length} projects for user $userId');
      return projects;
    } catch (e) {
      _logger.error('Error getting user projects: $e');
      rethrow;
    }
  }

  // Supprimer un projet
  Future<void> deleteProject(String projectId) async {
    try {
      await _client.from('projects').delete().eq('id', projectId);
      _logger.info('Project deleted: $projectId');
    } catch (e) {
      _logger.error('Error deleting project: $e');
      rethrow;
    }
  }

  // ==================== GESTION DES IMAGES ====================

  // Sauvegarder une image générée
  Future<GeneratedImageModel> saveGeneratedImage(
      GeneratedImageModel image) async {
    try {
      final response = await _client
          .from('generated_images')
          .insert(image.toJson())
          .select()
          .single();

      _logger.info('Image saved: ${image.id}');
      return GeneratedImageModel.fromJson(response);
    } catch (e) {
      _logger.error('Error saving image: $e');
      rethrow;
    }
  }

  // Récupérer les images d'un utilisateur
  Future<List<GeneratedImageModel>> getUserImages(String userId) async {
    try {
      final response = await _client
          .from('generated_images')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final images = (response as List)
          .map((json) => GeneratedImageModel.fromJson(json))
          .toList();

      _logger.info('Retrieved ${images.length} images for user $userId');
      return images;
    } catch (e) {
      _logger.error('Error getting user images: $e');
      rethrow;
    }
  }

  // Supprimer une image
  Future<void> deleteImage(String imageId) async {
    try {
      await _client.from('generated_images').delete().eq('id', imageId);
      _logger.info('Image deleted: $imageId');
    } catch (e) {
      _logger.error('Error deleting image: $e');
      rethrow;
    }
  }

  // ==================== GESTION DES UTILISATEURS ====================

  // Récupérer un utilisateur par ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromJson(response);
    } catch (e) {
      _logger.error('Error getting user: $e');
      rethrow;
    }
  }

  // Mettre à jour un utilisateur
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final response = await _client
          .from('users')
          .update(user.toJson())
          .eq('id', user.id)
          .select()
          .single();

      _logger.info('User updated: ${user.id}');
      return UserModel.fromJson(response);
    } catch (e) {
      _logger.error('Error updating user: $e');
      rethrow;
    }
  }

  // ==================== NETTOYAGE ET MAINTENANCE ====================

  // Nettoyer les anciens messages (plus vieux que X jours)
  Future<int> cleanupOldMessages(int days) async {
    try {
      final cutoffDate =
          DateTime.now().subtract(Duration(days: days)).toIso8601String();

      final response = await _client
          .from('messages')
          .delete()
          .lt('created_at', cutoffDate)
          .select();

      final count = (response as List).length;
      _logger.info('Cleaned up $count old messages');
      return count;
    } catch (e) {
      _logger.error('Error cleaning up old messages: $e');
      rethrow;
    }
  }

  // Compacter les données utilisateur
  Future<void> compactUserData(String userId) async {
    try {
      // Récupérer tous les messages de l'utilisateur
      final messages = await getUserMessages(userId, limit: 10000);

      if (messages.length > AppConstants.maxChatHistory) {
        // Garder seulement les plus récents
        final messagesToDelete = messages
            .take(messages.length - AppConstants.maxChatHistory)
            .toList();

        for (final message in messagesToDelete) {
          await deleteMessage(message.id);
        }

        _logger.info(
            'Compacted user data: deleted ${messagesToDelete.length} old messages');
      }
    } catch (e) {
      _logger.error('Error compacting user data: $e');
      rethrow;
    }
  }

  // Obtenir les statistiques d'utilisation
  Future<Map<String, dynamic>> getUsageStats(String userId) async {
    try {
      final messages = await getUserMessages(userId, limit: 10000);
      final projects = await getUserProjects(userId);
      final images = await getUserImages(userId);

      return {
        'totalMessages': messages.length,
        'askMessages': messages.where((m) => m.mode == 'ask').length,
        'agentMessages': messages.where((m) => m.mode == 'agent').length,
        'totalProjects': projects.length,
        'totalImages': images.length,
        'lastActivity': messages.isNotEmpty ? messages.last.createdAt : null,
      };
    } catch (e) {
      _logger.error('Error getting usage stats: $e');
      rethrow;
    }
  }

  // ==================== REALTIME SUBSCRIPTIONS ====================

  // S'abonner aux nouveaux messages
  RealtimeChannel subscribeToMessages(
    String userId,
    Function(MessageModel) onInsert,
  ) {
    final channel = _client
        .channel('messages:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final message = MessageModel.fromJson(payload.newRecord);
            onInsert(message);
          },
        )
        .subscribe();

    _logger.info('Subscribed to messages for user: $userId');
    return channel;
  }

  // Se désabonner
  Future<void> unsubscribeFromChannel(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
    _logger.info('Unsubscribed from channel');
  }
}
