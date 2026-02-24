import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/chat_service.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';

// Provider pour le ChatViewModel
final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return ChatViewModel(chatService, supabaseService, userId);
});

// Providers
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  throw UnimplementedError('Doit être override dans main.dart');
});

final currentUserIdProvider = Provider<String?>((ref) {
  throw UnimplementedError('Doit être override dans main.dart');
});

// État du chat
class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final String? error;
  final String currentMode;
  final bool isTyping;
  final String? detectedLanguage;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.currentMode = AppConstants.modeAsk,
    this.isTyping = false,
    this.detectedLanguage,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    String? error,
    String? currentMode,
    bool? isTyping,
    String? detectedLanguage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentMode: currentMode ?? this.currentMode,
      isTyping: isTyping ?? this.isTyping,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
    );
  }

  ChatState clearError() {
    return ChatState(
      messages: messages,
      isLoading: isLoading,
      error: null,
      currentMode: currentMode,
      isTyping: isTyping,
      detectedLanguage: detectedLanguage,
    );
  }

  // Obtenir les messages filtrés par mode
  List<MessageModel> getMessagesByMode(String mode) {
    return messages.where((m) => m.mode == mode).toList();
  }
}

class ChatViewModel extends StateNotifier<ChatState> {
  final ChatService _chatService;
  final SupabaseService _supabaseService;
  final String? _userId;
  final _logger = AppLogger('ChatViewModel');
  final _uuid = const Uuid();

  ChatViewModel(
    this._chatService,
    this._supabaseService,
    this._userId,
  ) : super(const ChatState()) {
    _init();
  }

  Future<void> _init() async {
    if (_userId != null) {
      await loadMessages();
    }
  }

  // Charger les messages existants
  Future<void> loadMessages() async {
    if (_userId == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final messages = await _supabaseService.getRecentMessages(_userId!);

      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );

      _logger.info('Loaded ${messages.length} messages');
    } catch (e) {
      _logger.error('Error loading messages: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des messages',
      );
    }
  }

  // Envoyer un message
  Future<void> sendMessage(String content) async {
    if (_userId == null) {
      state = state.copyWith(error: 'Utilisateur non connecté');
      return;
    }

    if (content.trim().isEmpty) {
      state = state.copyWith(error: 'Message vide');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      // Détecter la langue
      final language = _chatService.detectLanguage(content);
      state = state.copyWith(detectedLanguage: language);

      // Créer le message utilisateur
      final userMessage = MessageModel.userMessage(
        id: _uuid.v4(),
        userId: _userId!,
        content: content.trim(),
        mode: state.currentMode,
        language: language,
      );

      // Sauvegarder le message utilisateur
      await _supabaseService.saveMessage(userMessage);

      // Mettre à jour l'état avec le message utilisateur
      final updatedMessages = [...state.messages, userMessage];
      state = state.copyWith(
        messages: updatedMessages,
        isTyping: true,
      );

      // Obtenir la réponse de l'IA
      final response = await _chatService.sendMessage(
        message: content.trim(),
        mode: state.currentMode,
        language: language,
        conversationHistory: updatedMessages,
      );

      // Créer le message IA
      final aiMessage = MessageModel.aiMessage(
        id: _uuid.v4(),
        userId: _userId!,
        content: response,
        mode: state.currentMode,
        language: language,
      );

      // Sauvegarder le message IA
      await _supabaseService.saveMessage(aiMessage);

      // Mettre à jour l'état avec la réponse
      state = state.copyWith(
        messages: [...updatedMessages, aiMessage],
        isLoading: false,
        isTyping: false,
      );

      _logger.info('Message sent and response received');
    } catch (e) {
      _logger.error('Error sending message: $e');

      // Créer un message d'erreur
      final errorMessage = MessageModel.errorMessage(
        id: _uuid.v4(),
        userId: _userId!,
        content: 'Désolé, une erreur est survenue. Veuillez réessayer.',
        mode: state.currentMode,
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        isTyping: false,
        error: e.toString(),
      );
    }
  }

  // Changer de mode
  void setMode(String mode) {
    if (mode != state.currentMode) {
      state = state.copyWith(currentMode: mode);
      _logger.info('Mode changed to: $mode');
    }
  }

  // Basculer entre les modes
  void toggleMode() {
    final newMode = state.currentMode == AppConstants.modeAsk
        ? AppConstants.modeAgent
        : AppConstants.modeAsk;
    setMode(newMode);
  }

  // Effacer la conversation
  Future<void> clearConversation() async {
    if (_userId == null) return;

    try {
      state = state.copyWith(isLoading: true);

      await _supabaseService.deleteAllUserMessages(_userId!);

      state = state.copyWith(
        messages: [],
        isLoading: false,
      );

      _logger.info('Conversation cleared');
    } catch (e) {
      _logger.error('Error clearing conversation: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la suppression des messages',
      );
    }
  }

  // Supprimer un message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabaseService.deleteMessage(messageId);

      final updatedMessages =
          state.messages.where((m) => m.id != messageId).toList();

      state = state.copyWith(messages: updatedMessages);

      _logger.info('Message deleted: $messageId');
    } catch (e) {
      _logger.error('Error deleting message: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  // Effacer l'erreur
  void clearError() {
    state = state.clearError();
  }

  // Générer du code
  Future<String> generateCode({
    required String prompt,
    required String language,
    String? framework,
  }) async {
    try {
      return await _chatService.generateCode(
        prompt: prompt,
        language: language,
        framework: framework,
      );
    } catch (e) {
      _logger.error('Code generation error: $e');
      rethrow;
    }
  }

  // Créer un projet
  Future<ProjectModel> createProject({
    required String description,
    required String projectType,
    String? technologies,
  }) async {
    if (_userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final projectJson = await _chatService.createProject(
        description: description,
        projectType: projectType,
        technologies: technologies,
      );

      // Créer le projet à partir du JSON
      final project = ProjectModel(
        id: _uuid.v4(),
        userId: _userId!,
        name: projectJson['name'] ?? 'Projet sans nom',
        description: projectJson['description'] ?? '',
        files: (projectJson['files'] as List?)
                ?.map((f) => ProjectFile(
                      name: f['name'] ?? '',
                      path: f['path'] ?? '',
                      content: f['content'] ?? '',
                      language: f['language'] ?? 'text',
                    ))
                .toList() ??
            [],
        projectType: projectType,
        createdAt: DateTime.now(),
        metadata: {
          'instructions': projectJson['instructions'],
          'generated_at': DateTime.now().toIso8601String(),
        },
      );

      // Sauvegarder le projet
      await _supabaseService.saveProject(project);

      _logger.info('Project created: ${project.name}');
      return project;
    } catch (e) {
      _logger.error('Project creation error: $e');
      rethrow;
    }
  }

  // Analyser du code
  Future<String> analyzeCode(String code, {String? language}) async {
    try {
      return await _chatService.analyzeCode(
        code: code,
        language: language,
      );
    } catch (e) {
      _logger.error('Code analysis error: $e');
      rethrow;
    }
  }
}
