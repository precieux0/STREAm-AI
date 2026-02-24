class GeneratedImageModel {
  final String id;
  final String userId;
  final String prompt;
  final String? imageUrl;
  final String? localPath;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  final String? style;
  final String? size;

  GeneratedImageModel({
    required this.id,
    required this.userId,
    required this.prompt,
    this.imageUrl,
    this.localPath,
    required this.createdAt,
    this.metadata = const {},
    this.style,
    this.size,
  });

  factory GeneratedImageModel.fromJson(Map<String, dynamic> json) {
    return GeneratedImageModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      prompt: json['prompt'] as String,
      imageUrl: json['image_url'] as String?,
      localPath: json['local_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      style: json['style'] as String?,
      size: json['size'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'prompt': prompt,
      'image_url': imageUrl,
      'local_path': localPath,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
      'style': style,
      'size': size,
    };
  }

  bool get isLocal => localPath != null;
  bool get isRemote => imageUrl != null;

  GeneratedImageModel copyWith({
    String? id,
    String? userId,
    String? prompt,
    String? imageUrl,
    String? localPath,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    String? style,
    String? size,
  }) {
    return GeneratedImageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      prompt: prompt ?? this.prompt,
      imageUrl: imageUrl ?? this.imageUrl,
      localPath: localPath ?? this.localPath,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      style: style ?? this.style,
      size: size ?? this.size,
    );
  }
}
