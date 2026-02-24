import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../viewmodels/image_generation_viewmodel.dart';

class ImageGenerationView extends ConsumerStatefulWidget {
  const ImageGenerationView({super.key});

  @override
  ConsumerState<ImageGenerationView> createState() =>
      _ImageGenerationViewState();
}

class _ImageGenerationViewState extends ConsumerState<ImageGenerationView> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    await ref
        .read(imageGenerationViewModelProvider.notifier)
        .generateImage(prompt);

    _promptController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageGenerationViewModelProvider);
    final imageViewModel = ref.read(imageGenerationViewModelProvider.notifier);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // En-tête
          SliverToBoxAdapter(
            child: _buildHeader(imageState, imageViewModel),
          ),

          // Galerie d'images
          if (imageState.images.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final image = imageState.images[index];
                    return _buildImageCard(image);
                  },
                  childCount: imageState.images.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      ImageGenerationState imageState, ImageGenerationViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Génération d\'Images',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez des images uniques à partir de descriptions textuelles',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 16),

          // Champ de saisie du prompt
          TextField(
            controller: _promptController,
            decoration: InputDecoration(
              hintText: 'Décrivez l\'image que vous souhaitez générer...',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              suffixIcon: imageState.isGenerating
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      onPressed: _generateImage,
                      icon: const Icon(Icons.auto_awesome),
                    ),
            ),
            maxLines: 3,
            minLines: 1,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _generateImage(),
          ),

          const SizedBox(height: 16),

          // Options de style et taille
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Sélecteur de style
                _buildStyleSelector(imageState, viewModel),
                const SizedBox(width: 12),

                // Sélecteur de taille
                _buildSizeSelector(imageState, viewModel),
              ],
            ),
          ),

          // Barre de progression
          if (imageState.isGenerating && imageState.progress != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: imageState.progress! / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Génération en cours... ${imageState.progress}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

          // Message d'erreur
          if (imageState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.errorColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        imageState.error!,
                        style: const TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                    IconButton(
                      onPressed: viewModel.clearError,
                      icon: const Icon(Icons.close, color: AppTheme.errorColor),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStyleSelector(
      ImageGenerationState state, ImageGenerationViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: state.selectedStyle,
          hint: const Text('Style'),
          isDense: true,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Style par défaut'),
            ),
            ...viewModel.availableStyles.map((style) {
              return DropdownMenuItem(
                value: style['id'],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(style['icon']!),
                    const SizedBox(width: 8),
                    Text(style['name']!),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) => viewModel.setStyle(value),
        ),
      ),
    );
  }

  Widget _buildSizeSelector(
      ImageGenerationState state, ImageGenerationViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: state.selectedSize,
          hint: const Text('Taille'),
          isDense: true,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('1024×1024'),
            ),
            ...viewModel.availableSizes.map((size) {
              return DropdownMenuItem(
                value: size['id'],
                child: Text(size['name']!),
              );
            }),
          ],
          onChanged: (value) => viewModel.setSize(value),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune image générée',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Décrivez une image et appuyez sur le bouton pour la générer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(dynamic image) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          if (image.imageUrl != null)
            Image.network(
              image.imageUrl! as String,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                );
              },
            )
          else
            Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image),
            ),

          // Overlay avec le prompt
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    image.prompt as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (image.style != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        image.style as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bouton de suppression
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withOpacity(0.5),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  ref
                      .read(imageGenerationViewModelProvider.notifier)
                      .deleteImage(image.id as String);
                },
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}
