import 'package:flutter_test/flutter_test.dart';
import 'package:stream_ai/models/models.dart';

void main() {
  group('UserModel Tests', () {
    test('should create UserModel from JSON', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'name': 'Test User',
        'photo_url': 'https://example.com/photo.jpg',
        'created_at': '2024-01-01T00:00:00.000Z',
        'preferences': {'theme': 'dark'},
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
      expect(user.preferences['theme'], 'dark');
    });

    test('should convert UserModel to JSON', () {
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
    });
  });

  group('MessageModel Tests', () {
    test('should create MessageModel from JSON', () {
      final json = {
        'id': 'msg-123',
        'user_id': 'user-123',
        'content': 'Hello World',
        'is_user': true,
        'mode': 'ask',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final message = MessageModel.fromJson(json);

      expect(message.id, 'msg-123');
      expect(message.userId, 'user-123');
      expect(message.content, 'Hello World');
      expect(message.isUser, true);
      expect(message.mode, 'ask');
    });

    test('should create user message', () {
      final message = MessageModel.userMessage(
        id: 'msg-123',
        userId: 'user-123',
        content: 'Hello',
        mode: 'ask',
      );

      expect(message.isUser, true);
      expect(message.content, 'Hello');
    });

    test('should create AI message', () {
      final message = MessageModel.aiMessage(
        id: 'msg-123',
        userId: 'user-123',
        content: 'Hi there!',
        mode: 'ask',
      );

      expect(message.isUser, false);
      expect(message.content, 'Hi there!');
    });
  });

  group('ProjectModel Tests', () {
    test('should calculate total lines correctly', () {
      final project = ProjectModel(
        id: 'proj-123',
        userId: 'user-123',
        name: 'Test Project',
        description: 'A test project',
        files: [
          ProjectFile(
            name: 'main.dart',
            path: 'lib/main.dart',
            content: 'void main() {\n  print("Hello");\n}\n',
            language: 'dart',
          ),
          ProjectFile(
            name: 'utils.dart',
            path: 'lib/utils.dart',
            content: 'class Utils {\n  static void helper() {}\n}\n',
            language: 'dart',
          ),
        ],
        projectType: 'flutter',
        createdAt: DateTime.now(),
      );

      expect(project.totalLines, 6);
      expect(project.files.length, 2);
    });

    test('should get unique languages', () {
      final project = ProjectModel(
        id: 'proj-123',
        userId: 'user-123',
        name: 'Test Project',
        description: 'A test project',
        files: [
          ProjectFile(
            name: 'main.dart',
            path: 'lib/main.dart',
            content: 'void main() {}',
            language: 'dart',
          ),
          ProjectFile(
            name: 'script.js',
            path: 'js/script.js',
            content: 'console.log("hi");',
            language: 'javascript',
          ),
        ],
        projectType: 'web',
        createdAt: DateTime.now(),
      );

      expect(project.languages.length, 2);
      expect(project.languages.contains('dart'), true);
      expect(project.languages.contains('javascript'), true);
    });
  });
}
