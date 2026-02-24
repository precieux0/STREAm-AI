import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/generated_image_model.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';

class ImageGenerationService {

  String enhancePrompt(String prompt, String? style) {
    final buffer = StringBuffer();
    switch (style?.toLowerCase()) {
      case 'photographic':
        buffer.write('professional photography, high quality, detailed, ');
        break;
      case 'digital-art':
        buffer.write('digital art, vibrant colors, detailed, ');
        break;
      case 'cinematic':
        buffer.write('cinematic shot, dramatic lighting, ');
        break;
      case 'anime':
        buffer.write('anime style, vibrant, detailed, ');
        break;
      default:
        buffer.write('high quality, detailed, ');
    }
    buffer.write(prompt);
    return buffer.toString();
  }

  final Dio _dio;
  final _logger = AppLogger('ImageGenerationService');
  final _uuid = const Uuid();

  // TES APIs de génération d'images
  late final String _eliasBaseUrl;  // Elias AR
  late final String _fluxBaseUrl;   // Flux API

  ImageGenerationService() : _dio = Dio() {
    _eliasBaseUrl = 'https://eliasar-yt-api.vercel.app';
    _fluxBaseUrl = 'https://1yjs1yldj7.execute-api.us-east-1.amazonaws.com/default/ai_image';

    _dio.options.connectTimeout =
        const Duration(seconds: AppConstants.connectionTimeoutSeconds);
    _dio.options.receiveTimeout =
        const Duration(seconds: AppConstants.apiTimeoutSeconds * 2);
  }

  // Générer une image à partir d'un prompt
  Future<GeneratedImageModel> generateImage({
    required String userId,
    required String prompt,
    String? style,
    String? size,
    int? seed,
  }) async {
    try {
      _logger.info('Generating image for prompt: $prompt');

      // Améliorer le prompt avec le style
      final enhancedPrompt = _enhancePrompt(prompt, style);
      
      // Essayer d'abord avec Elias AR (image binaire)
      String? imageUrl;
      try {
        imageUrl = await _generateWithElias(enhancedPrompt);
        _logger.info('Image generated with Elias AR');
      } catch (e) {
        _logger.warning('Elias AR failed, trying Flux: $e');
        // Fallback vers Flux (URL d'image)
        imageUrl = await _generateWithFlux(enhancedPrompt, size);
      }

      if (imageUrl == null) {
        throw Exception('Échec de la génération d\'image');
      }

      // Créer le modèle
      final imageModel = GeneratedImageModel(
        id: _uuid.v4(),
        userId: userId,
        prompt: prompt,
        imageUrl: imageUrl,
        localPath: imageUrl.startsWith('http') ? null : imageUrl,
        createdAt: DateTime.now(),
        style: style,
        size: size,
        metadata: {
          'seed': seed,
          'api_used': imageUrl.startsWith('http') ? 'flux' : 'elias',
          'enhanced_prompt': enhancedPrompt,
        },
      );

      _logger.info('Image generated: ${imageModel.id}');
      return imageModel;
    } catch (e) {
      _logger.error('Image generation error: $e');
      rethrow;
    }
  }

  // === TES APIs SPÉCIFIQUES ===

  // 1. Elias AR - retourne une image binaire
  Future<String?> _generateWithElias(String prompt) async {
    try {
      // URL: https://eliasar-yt-api.vercel.app/api/ai/text2img?prompt=DESCRIPTION
      final response = await _dio.get(
        '$_eliasBaseUrl/api/ai/text2img',
        queryParameters: {'prompt': prompt},
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (status) => status! < 500, // Accepte 200, 404, etc.
        ),
      );

      if (response.statusCode == 200) {
        // Sauvegarder l'image temporairement
        final tempDir = await getTemporaryDirectory();
        final fileName = 'stream_ai_elias_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(Uint8List.fromList(List<int>.from(response.data)));
        
        _logger.info('Elias image saved to: ${file.path}');
        return file.path; // Retourne le chemin local
      } else if (response.statusCode == 500) {
        _logger.warning('Elias AR returned 500 (probablement instable)');
        return null;
      }
      return null;
    } on DioException catch (e) {
      _logger.warning('Elias AR error: ${e.message}');
      return null;
    }
  }

  // 2. Flux API - retourne une URL d'image
  Future<String?> _generateWithFlux(String prompt, String? size) async {
    try {
      // URL: https://1yjs1yldj7.execute-api.us-east-1.amazonaws.com/default/ai_image
      // Paramètres: prompt, aspect_ratio (ex: 2:3, 1:1, 16:9)
      final aspectRatio = _sizeToAspectRatio(size);
      
      final response = await _dio.get(
        _fluxBaseUrl,
        queryParameters: {
          'prompt': prompt,
          'aspect_ratio': aspectRatio,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Réponse: { "image_link": "url_image", "status": "success" }
        if (data['image_link'] != null) {
          return data['image_link'] as String;
        }
      }
      return null;
    } on DioException catch (e) {
      _logger.warning('Flux API error: ${e.message}');
      return null;
    }
  }

  // Convertir la taille en aspect ratio pour Flux
  String _sizeToAspectRatio(String? size) {
    switch (size) {
      case '1024x1024':
        return '1:1';
      case '1024x768':
        return '4:3';
      case '768x1024':
        return '3:4';
      case '512x512':
        return '1:1';
      default:
        return '2:3'; // Format par défaut
    }
  }

  // === MÉTHODES EXISTANTES CONSERVÉES (adaptées) ===

  // Sauvegarder une image localement
  Future<String> saveImageLocally({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images/$userId');

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final filePath = '${imagesDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      _logger.info('Image saved locally: $filePath');
      return filePath;
    } catch (e) {
      _logger.error('Error saving image locally: $e');
      rethrow;
    }
  }

  // Télécharger une image depuis une URL
  Future<Uint8List> downloadImage(String imageUrl) async {
    try {
      if (imageUrl.startsWith('file://') || imageUrl.startsWith('/')) {
        // C'est un fichier local
        final file = File(imageUrl.replaceFirst('file://', ''));
        return await file.readAsBytes();
      }

      final response = await _dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      return Uint8List.fromList(List<int>.from(response.data));
    } catch (e) {
      _logger.error('Error downloading image: $e');
      rethrow;
    }
  }

  // Supprimer une image locale
  Future<void> deleteLocalImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _logger.info('Local image deleted: $filePath');
      }
    } catch (e) {
      _logger.error('Error deleting local image: $e');
      rethrow;
    }
  }

  // Styles disponibles (inchangé)
  List<Map<String, String>> get availableStyles {
    return [
      {'id': 'photographic', 'name': 'Photographique', 'icon': '📷'},
      {'id': 'digital-art', 'name': 'Art Numérique', 'icon': '🎨'},
      {'id': 'cinematic', 'name': 'Cinématique', 'icon': '🎬'},
      {'id': 'anime', 'name': 'Anime', 'icon': '🇯🇵'},
      {'id': 'fantasy-art', 'name': 'Art Fantastique', 'icon': '🐉'},
      {'id': 'line-art', 'name': 'Dessin au Trait', 'icon': '✏️'},
      {'id': '3d-model', 'name': 'Modèle 3D', 'icon': '🎲'},
    ];
  }

  // Tailles disponibles
  List<Map<String, String>> get availableSizes {
    return [
      {'id': '1024x1024', 'name': 'Carré (1:1)', 'dimensions': '1024×1024'},
      {'id': '1024x768', 'name': 'Paysage (4:3)', 'dimensions': '1024×768'},
      {'id': '768x1024', 'name': 'Portrait (3:4)', 'dimensions': '768×1024'},
      {'id': '512x512', 'name': 'Petit Carré', 'dimensions': '512×512'},
    ];
  }

  // Améliorer un prompt
  String _enhancePrompt(String prompt, String? style) {
    final buffer = StringBuffer();

    // Ajouter des modificateurs selon le style
    switch (style?.toLowerCase()) {
      case 'photographic':
        buffer.write('professional photography, high quality, detailed, realistic, ');
        break;
      case 'digital-art':
        buffer.write('digital art, vibrant colors, detailed illustration, ');
        break;
      case 'cinematic':
        buffer.write('cinematic shot, dramatic lighting, film grain, movie scene, ');
        break;
      case 'anime':
        buffer.write('anime style, manga, vibrant, detailed anime artwork, ');
        break;
      case 'fantasy-art':
        buffer.write('fantasy art, magical, ethereal, detailed fantasy scene, ');
        break;
      case '3d-model':
        buffer.write('3D render, octane render, high quality 3D, blender render, ');
        break;
      default:
        buffer.write('high quality, detailed, beautiful, ');
    }

    buffer.write(prompt);
    return buffer.toString();
  }
}