import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/generated_image_model.dart';
import '../services/image_generation_service.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';

// Provider pour le ImageGenerationViewModel
final imageGenerationViewModelProvider =
    StateNotifierProvider<ImageGenerationViewModel, ImageGenerationState>(
        (ref) {
  final imageService = ref.watch(imageGenerationServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  final imageService = ref.watch(imageGenerationServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  final imageService = ref.watch(imageGenerationServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  final imageService = ref.watch(imageGenerationServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

final imageGenerationServiceProvider =
    Provider<ImageGenerationService>((ref) => ImageGenerationService());

// État de la génération d'images
class ImageGenerationState {
  final List<GeneratedImageModel> images;
  final bool isGenerating;
  final String? error;
  final String? currentPrompt;
  final String? selectedStyle;
  final String? selectedSize;
  final int? progress;

  const ImageGenerationState({
    this.images = const [],
    this.isGenerating = false,
    this.error,
    this.currentPrompt,
    this.selectedStyle,
    this.selectedSize,
    this.progress,
  });

  ImageGenerationState copyWith({
    List<GeneratedImageModel>? images,
    bool? isGenerating,
    String? error,
    String? currentPrompt,
    String? selectedStyle,
    String? selectedSize,
    int? progress,
  }) {
    return ImageGenerationState(
      images: images ?? this.images,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
      currentPrompt: currentPrompt ?? this.currentPrompt,
      selectedStyle: selectedStyle ?? this.selectedStyle,
      selectedSize: selectedSize ?? this.selectedSize,
      progress: progress ?? this.progress,
    );
  }

  ImageGenerationState clearError() {
    return ImageGenerationState(
      images: images,
      isGenerating: isGenerating,
      error: null,
      currentPrompt: currentPrompt,
      selectedStyle: selectedStyle,
      selectedSize: selectedSize,
      progress: progress,
    );
  }
}

class ImageGenerationViewModel extends StateNotifier<ImageGenerationState> {
  final ImageGenerationService _imageService;
  final SupabaseService _supabaseService;
  final String? _userId;
  final _logger = AppLogger('ImageGenerationViewModel');

  ImageGenerationViewModel(
    this._imageService,
    this._supabaseService,
    this._userId,
  ) : super(const ImageGenerationState()) {
    _init();
  }

  Future<void> _init() async {
    if (_userId != null) {
      await loadImages();
    }
  }

  // Charger les images existantes
  Future<void> loadImages() async {
    if (_userId == null) return;

    try {
      final images = await _supabaseService.getUserImages(_userId!);

      state = state.copyWith(images: images);

      _logger.info('Loaded ${images.length} images');
    } catch (e) {
      _logger.error('Error loading images: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  // Générer une image
  Future<GeneratedImageModel?> generateImage(String prompt) async {
    if (_userId == null) {
      state = state.copyWith(error: 'Utilisateur non connecté');
      return null;
    }

    if (prompt.trim().isEmpty) {
      state = state.copyWith(error: 'Prompt vide');
      return null;
    }

    try {
      state = state.copyWith(
        isGenerating: true,
        error: null,
        currentPrompt: prompt.trim(),
        progress: 0,
      );

      // Améliorer le prompt
      final enhancedPrompt = _imageService.enhancePrompt(
        prompt.trim(),
        state.selectedStyle,
      );

      state = state.copyWith(progress: 30);

      // Générer l'image
      final image = await _imageService.generateImage(
        userId: _userId!,
        prompt: enhancedPrompt,
        style: state.selectedStyle,
        size: state.selectedSize,
      );

      state = state.copyWith(progress: 80);

      // Sauvegarder dans Supabase
      await _supabaseService.saveGeneratedImage(image);

      state = state.copyWith(progress: 100);

      // Mettre à jour l'état
      final updatedImages = [image, ...state.images];
      state = state.copyWith(
        images: updatedImages,
        isGenerating: false,
        progress: null,
      );

      _logger.info('Image generated: ${image.id}');
      return image;
    } catch (e) {
      _logger.error('Image generation error: $e');
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
        progress: null,
      );
      return null;
    }
  }

  // Définir le style
  void setStyle(String? style) {
    state = state.copyWith(selectedStyle: style);
  }

  // Définir la taille
  void setSize(String? size) {
    state = state.copyWith(selectedSize: size);
  }

  // Supprimer une image
  Future<void> deleteImage(String imageId) async {
    try {
      await _supabaseService.deleteImage(imageId);

      final updatedImages =
          state.images.where((img) => img.id != imageId).toList();

      state = state.copyWith(images: updatedImages);

      _logger.info('Image deleted: $imageId');
    } catch (e) {
      _logger.error('Error deleting image: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  // Effacer l'erreur
  void clearError() {
    state = state.clearError();
  }

  // Obtenir les styles disponibles
  List<Map<String, String>> get availableStyles =>
      _imageService.availableStyles;

  // Obtenir les tailles disponibles
  List<Map<String, String>> get availableSizes => _imageService.availableSizes;
}
