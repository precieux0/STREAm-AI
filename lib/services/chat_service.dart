import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/models.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';

class ChatService {
  final Dio _dio;
  final _logger = AppLogger('ChatService');

  // TES APIs
  late final String _deliriusBaseUrl;
  late final String _zenBaseUrl;

  // Pour suivre quelle API utiliser (round-robin simple)
  int _currentApiIndex = 0;
  final List<String> _zenEndpoints = ['gemini', 'grok-3-mini', 'qwen-qwq-32b'];

  ChatService() : _dio = Dio() {
    _deliriusBaseUrl = AppConstants.deliriusApiBaseUrl;
    _zenBaseUrl = AppConstants.zenApiBaseUrl;

    _dio.options.connectTimeout =
        const Duration(seconds: AppConstants.connectionTimeoutSeconds);
    _dio.options.receiveTimeout =
        const Duration(seconds: AppConstants.apiTimeoutSeconds);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Envoyer un message et obtenir une réponse
  Future<String> sendMessage({
    required String message,
    required String mode,
    String? language,
    List<MessageModel>? conversationHistory,
  }) async {
    try {
      _logger.info('Sending message in $mode mode, language: $language');

      // Construire le prompt selon le mode et le contexte
      final fullPrompt = _buildPrompt(
        message: message,
        mode: mode,
        language: language,
        history: conversationHistory,
      );

      // Essayer Delirius d'abord, puis ZenZxz
      try {
        final response = await _sendToDelirius(fullPrompt);
        if (response != null) {
          _logger.info('Response received from Delirius');
          return response;
        }
      } catch (e) {
        _logger.warning('Delirius failed: $e');
      }

      // Fallback vers ZenZxz
      final response = await _sendToZenZxz(fullPrompt);
      if (response != null) {
        _logger.info('Response received from ZenZxz');
        return response;
      }

      throw Exception('Toutes les APIs ont échoué');
    } catch (e) {
      _logger.error('All AI services failed: $e');
      throw Exception(
          'Impossible d\'obtenir une réponse. Veuillez réessayer plus tard.');
    }
  }

  // API Delirius (GET avec text et prompt)
  Future<String?> _sendToDelirius(String prompt) async {
    try {
      final response = await _dio.get(
        '$_deliriusBaseUrl/ia/gptprompt',
        queryParameters: {
          'text': prompt,
          'prompt': _getSystemPromptForDelirius(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          return data['data'] as String;
        }
      }
      return null;
    } on DioException catch (e) {
      _logger.warning('Delirius API error: ${e.message}');
      return null;
    } catch (e) {
      _logger.warning('Delirius API unexpected error: $e');
      return null;
    }
  }

  // API ZenZxz (GET avec endpoint rotatif)
  Future<String?> _sendToZenZxz(String prompt) async {
    try {
      // Rotation des endpoints
      _currentApiIndex = (_currentApiIndex + 1) % _zenEndpoints.length;
      final endpoint = _zenEndpoints[_currentApiIndex];
      
      final response = await _dio.get(
        '$_zenBaseUrl/ai/$endpoint',
        queryParameters: {'text': prompt},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return (data["response"] ?? data["assistant"]) as String?;
      }
      return null;
    } on DioException catch (e) {
      _logger.warning('ZenZxz API error: ${e.message}');
      return null;
    } catch (e) {
      _logger.warning('ZenZxz API unexpected error: $e');
      return null;
    }
  }

  // Construire le prompt complet avec contexte
  String _buildPrompt({
    required String message,
    required String mode,
    String? language,
    List<MessageModel>? history,
  }) {
    final lang = language ?? 'fr';
    final systemPrompt = _getSystemPrompt(mode, lang);
    
    // Ajouter l'historique si disponible
    String historyText = '';
    if (history != null && history.isNotEmpty) {
      historyText = '\nHistorique de la conversation:\n';
      for (final msg in history.take(5)) {
        final role = msg.isUser ? 'Utilisateur' : 'Assistant';
        historyText += '$role: ${msg.content}\n';
      }
    }

    return '''
$systemPrompt

$historyText

Message actuel: $message

Réponds de manière claire et utile en ${lang == 'fr' ? 'français' : lang}.
''';
  }

  // Prompt système pour Delirius
  String _getSystemPromptForDelirius() {
    return '''Tu es Stream AI, un assistant intelligent et serviable.
Tu réponds aux questions de manière claire, concise et utile.
Tu adaptes ton langage au niveau de l'utilisateur et tu es toujours poli.
Si on te demande du code, fournis-le avec des commentaires clairs.''';
  }

  // Prompt système complet
  String _getSystemPrompt(String mode, String language) {
    if (mode == 'agent') {
      return '''Tu es Stream AI Agent, un assistant de programmation expert. 
Tu peux générer du code dans n'importe quel langage, créer des projets complets, et fournir des analyses techniques.
Tes réponses doivent être structurées, professionnelles et inclure des commentaires dans le code.
Quand on te demande de créer un projet, fournis la structure complète avec tous les fichiers nécessaires.
Réponds en ${language == 'fr' ? 'français' : language}.''';
    } else {
      return '''Tu es Stream AI, un assistant intelligent et serviable.
Tu réponds aux questions de manière claire, concise et utile.
Tu adaptes ton langage au niveau de l'utilisateur et tu es toujours poli.
Si tu ne connais pas la réponse, tu l'admets honnêtement.
Réponds en ${language == 'fr' ? 'français' : language}.''';
    }
  }

  // Générer du code avec contexte
  Future<String> generateCode({
    required String prompt,
    required String language,
    String? framework,
  }) async {
    try {
      final enhancedPrompt = '''
Génère du code $language ${framework != null ? 'avec $framework' : ''} pour:
$prompt

Fournis uniquement le code avec des commentaires, sans explications supplémentaires.
''';

      return await sendMessage(
        message: enhancedPrompt,
        mode: 'agent',
        language: 'fr',
      );
    } catch (e) {
      _logger.error('Code generation error: $e');
      rethrow;
    }
  }

  // Créer un projet complet
  Future<Map<String, dynamic>> createProject({
    required String description,
    required String projectType,
    String? technologies,
  }) async {
    try {
      final prompt = '''
Crée un projet complet de type "$projectType" avec la description suivante:
$description

${technologies != null ? 'Technologies à utiliser: $technologies' : ''}

Fournis la réponse au format JSON avec la structure suivante:
{
  "name": "nom_du_projet",
  "description": "description courte",
  "files": [
    {
      "name": "nom_fichier",
      "path": "chemin/relatif",
      "content": "contenu_du_fichier",
      "language": "langage"
    }
  ],
  "instructions": "instructions d'installation"
}
''';

      final response = await sendMessage(
        message: prompt,
        mode: 'agent',
        language: 'fr',
      );

      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      }

      throw Exception('Format de réponse invalide');
    } catch (e) {
      _logger.error('Project creation error: $e');
      rethrow;
    }
  }

  // Analyser du code
  Future<String> analyzeCode({
    required String code,
    String? language,
  }) async {
    try {
      final prompt = '''
Analyse le code suivant ${language != null ? '($language)' : ''} et fournis:
1. Un résumé de ce que fait le code
2. Les points forts
3. Les problèmes potentiels ou améliorations possibles
4. Une note sur 10

Code:
```

$code

```
''';

      return await sendMessage(
        message: prompt,
        mode: 'agent',
        language: 'fr',
      );
    } catch (e) {
      _logger.error('Code analysis error: $e');
      rethrow;
    }
  }

  // Détecter la langue du texte
  String detectLanguage(String text) {
    final lowerText = text.toLowerCase();

    if (RegExp(r'\b(le|la|les|un|une|des|et|ou|mais|donc|car|je|tu|il|elle|nous|vous|ils|elles|suis|es|est|sommes|êtes|sont)\b')
        .hasMatch(lowerText)) {
      return 'fr';
    }

    if (RegExp(r'\b(the|a|an|and|or|but|so|because|i|you|he|she|we|they|am|is|are|was|were|be|been|being)\b')
        .hasMatch(lowerText)) {
      return 'en';
    }

    return 'fr';
  }
}