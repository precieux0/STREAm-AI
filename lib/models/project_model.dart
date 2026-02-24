class ProjectFile {
  final String name;
  final String path;
  final String content;
  final String language;

  ProjectFile({
    required this.name,
    required this.path,
    required this.content,
    required this.language,
  });

  factory ProjectFile.fromJson(Map<String, dynamic> json) {
    return ProjectFile(
      name: json['name'] as String,
      path: json['path'] as String,
      content: json['content'] as String,
      language: json['language'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'content': content,
      'language': language,
    };
  }
}

class ProjectModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final List<ProjectFile> files;
  final String projectType;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  ProjectModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.files,
    required this.projectType,
    required this.createdAt,
    this.metadata = const {},
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      files: (json['files'] as List)
          .map((f) => ProjectFile.fromJson(f as Map<String, dynamic>))
          .toList(),
      projectType: json['project_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'files': files.map((f) => f.toJson()).toList(),
      'project_type': projectType,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Obtenir la taille totale du projet en bytes
  int get totalSize {
    return files.fold(0, (sum, file) => sum + file.content.length);
  }

  // Obtenir le nombre de lignes de code total
  int get totalLines {
    return files.fold(0, (sum, file) {
      return sum + '\n'.allMatches(file.content).length + 1;
    });
  }

  // Obtenir la liste des langages utilisés
  List<String> get languages {
    return files.map((f) => f.language).toSet().toList();
  }

  ProjectModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<ProjectFile>? files,
    String? projectType,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      files: files ?? this.files,
      projectType: projectType ?? this.projectType,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
