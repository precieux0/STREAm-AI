class MessageModel {
  final String id;
  final String userId;
  final String content;
  final bool isUser;
  final String mode; // 'ask' ou 'agent'
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final String? language;
  final List<String>? attachments;
  final bool isError;
  final bool isTyping;

  MessageModel({
    required this.id,
    required this.userId,
    required this.content,
    this.isUser = true,
    this.mode = 'ask',
    this.metadata = const {},
    required this.createdAt,
    this.language,
    this.attachments,
    this.isError = false,
    this.isTyping = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      isUser: json['is_user'] as bool? ?? true,
      mode: json['mode'] as String? ?? 'ask',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      language: json['language'] as String?,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
      isError: json['is_error'] as bool? ?? false,
      isTyping: json['is_typing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'is_user': isUser,
      'mode': mode,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'language': language,
      'attachments': attachments,
      'is_error': isError,
      'is_typing': isTyping,
    };
  }

  MessageModel copyWith({
    String? id,
    String? userId,
    String? content,
    bool? isUser,
    String? mode,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    String? language,
    List<String>? attachments,
    bool? isError,
    bool? isTyping,
  }) {
    return MessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      mode: mode ?? this.mode,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      language: language ?? this.language,
      attachments: attachments ?? this.attachments,
      isError: isError ?? this.isError,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  // Constructeur pour message utilisateur
  factory MessageModel.userMessage({
    required String id,
    required String userId,
    required String content,
    String mode = 'ask',
    String? language,
  }) {
    return MessageModel(
      id: id,
      userId: userId,
      content: content,
      isUser: true,
      mode: mode,
      createdAt: DateTime.now(),
      language: language,
    );
  }

  // Constructeur pour message IA
  factory MessageModel.aiMessage({
    required String id,
    required String userId,
    required String content,
    String mode = 'ask',
    String? language,
    Map<String, dynamic> metadata = const {},
  }) {
    return MessageModel(
      id: id,
      userId: userId,
      content: content,
      isUser: false,
      mode: mode,
      metadata: metadata,
      createdAt: DateTime.now(),
      language: language,
    );
  }

  // Constructeur pour message d'erreur
  factory MessageModel.errorMessage({
    required String id,
    required String userId,
    required String content,
    String mode = 'ask',
  }) {
    return MessageModel(
      id: id,
      userId: userId,
      content: content,
      isUser: false,
      mode: mode,
      createdAt: DateTime.now(),
      isError: true,
    );
  }

  // Constructeur pour indicateur de frappe
  factory MessageModel.typingIndicator({
    required String id,
    required String userId,
    String mode = 'ask',
  }) {
    return MessageModel(
      id: id,
      userId: userId,
      content: '',
      isUser: false,
      mode: mode,
      createdAt: DateTime.now(),
      isTyping: true,
    );
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, isUser: $isUser, mode: $mode, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
  }
}
