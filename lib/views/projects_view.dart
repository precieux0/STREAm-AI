import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../models/project_model.dart';
import '../services/project_export_service.dart';

class ProjectsView extends ConsumerStatefulWidget {
  const ProjectsView({super.key});

  @override
  ConsumerState<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends ConsumerState<ProjectsView> {
  final ProjectExportService _exportService = ProjectExportService();
  bool _isCreatingProject = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // En-tête
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          // Liste des projets (sera implémentée avec les données réelles)
          SliverFillRemaining(
            child: _buildEmptyState(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCreatingProject ? null : _showCreateProjectDialog,
        icon: _isCreatingProject
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add),
        label: Text(_isCreatingProject ? 'Création...' : 'Nouveau projet'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.agentModeGradient.colors.first.withOpacity(0.1),
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
            'Mes Projets',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gérez et exportez vos projets générés par l\'IA',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.folder_open_outlined,
              size: 50,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun projet encore',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Créez votre premier projet en utilisant le mode Agent dans le chat',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showCreateProjectDialog,
            icon: const Icon(Icons.add),
            label: const Text('Créer un projet'),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  void _showCreateProjectDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final technologiesController = TextEditingController();
    String selectedType = 'web';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nouveau Projet',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Type de projet
                Text(
                  'Type de projet',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildProjectTypeChip(
                      'Site Web',
                      'web',
                      Icons.language,
                      selectedType,
                      (type) => setState(() => selectedType = type),
                    ),
                    _buildProjectTypeChip(
                      'Application Mobile',
                      'mobile',
                      Icons.phone_android,
                      selectedType,
                      (type) => setState(() => selectedType = type),
                    ),
                    _buildProjectTypeChip(
                      'API Backend',
                      'backend',
                      Icons.storage,
                      selectedType,
                      (type) => setState(() => selectedType = type),
                    ),
                    _buildProjectTypeChip(
                      'Script/Tool',
                      'script',
                      Icons.code,
                      selectedType,
                      (type) => setState(() => selectedType = type),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Nom du projet
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du projet',
                    hintText: 'Mon super projet',
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Décrivez ce que vous voulez créer...',
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // Technologies
                TextField(
                  controller: technologiesController,
                  decoration: const InputDecoration(
                    labelText: 'Technologies (optionnel)',
                    hintText: 'Ex: Flutter, React, Node.js...',
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton créer
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _createProject(
                        name: nameController.text,
                        description: descriptionController.text,
                        projectType: selectedType,
                        technologies: technologiesController.text.isEmpty
                            ? null
                            : technologiesController.text,
                      );
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Générer le projet'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectTypeChip(
    String label,
    String type,
    IconData icon,
    String selectedType,
    Function(String) onSelected,
  ) {
    final isSelected = selectedType == type;
    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onSelected(type),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Future<void> _createProject({
    required String name,
    required String description,
    required String projectType,
    String? technologies,
  }) async {
    if (description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une description')),
      );
      return;
    }

    setState(() {
      _isCreatingProject = true;
    });

    try {
      final fullDescription = name.trim().isNotEmpty
          ? '${name.trim()}\n\n${description.trim()}'
          : description.trim();

      final project = await ref.read(chatViewModelProvider.notifier).createProject(
            description: fullDescription,
            projectType: projectType,
            technologies: technologies,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Projet "${project.name}" créé avec succès !'),
            action: SnackBarAction(
              label: 'Voir',
              onPressed: () => _showProjectDetails(project),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() {
        _isCreatingProject = false;
      });
    }
  }

  void _showProjectDetails(ProjectModel project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Chip(
                    label: Text('${project.files.length} fichiers'),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('${project.totalLines} lignes'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: project.files.length,
                  itemBuilder: (context, index) {
                    final file = project.files[index];
                    return ListTile(
                      leading: Icon(
                        Icons.description_outlined,
                        color: AppTheme.getLanguageColor(file.language),
                      ),
                      title: Text(file.name),
                      subtitle: Text(file.path),
                      trailing: Text(
                        file.language.toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.getLanguageColor(file.language),
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => _showFileContent(file),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _exportProject(project),
                      icon: const Icon(Icons.download),
                      label: const Text('Télécharger ZIP'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _shareProject(project),
                      icon: const Icon(Icons.share),
                      label: const Text('Partager'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFileContent(ProjectFile file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      file.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                file.language.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.getLanguageColor(file.language),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      file.content,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportProject(ProjectModel project) async {
    try {
      final path = await _exportService.exportToZip(project);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Projet exporté: $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'export: $e')),
        );
      }
    }
  }

  Future<void> _shareProject(ProjectModel project) async {
    try {
      await _exportService.shareProject(project);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de partage: $e')),
        );
      }
    }
  }
}
