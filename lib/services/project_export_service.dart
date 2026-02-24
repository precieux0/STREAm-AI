import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/project_model.dart';
import '../utils/logger.dart';

class ProjectExportService {
  final _logger = AppLogger('ProjectExportService');

  // Exporter un projet au format ZIP
  Future<String> exportToZip(ProjectModel project) async {
    try {
      _logger.info('Exporting project to ZIP: ${project.name}');

      // Créer l'archive
      final archive = Archive();

      // Ajouter chaque fichier au ZIP
      for (final file in project.files) {
        final fileData = Uint8List.fromList(file.content.codeUnits);
        final archiveFile = ArchiveFile(
          file.path,
          fileData.length,
          fileData,
        );
        archive.addFile(archiveFile);
      }

      // Ajouter un fichier README
      final readmeContent = _generateReadme(project);
      final readmeData = Uint8List.fromList(readmeContent.codeUnits);
      archive.addFile(ArchiveFile('README.md', readmeData.length, readmeData));

      // Encoder l'archive
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      if (zipData == null) {
        throw Exception('Erreur lors de l\'encodage ZIP');
      }

      // Sauvegarder le fichier
      final directory = await getTemporaryDirectory();
      final zipPath = '${directory.path}/${project.name}.zip';
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipData);

      _logger.info('Project exported to: $zipPath');
      return zipPath;
    } catch (e) {
      _logger.error('Error exporting project to ZIP: $e');
      rethrow;
    }
  }

  // Partager un projet
  Future<void> shareProject(ProjectModel project) async {
    try {
      final zipPath = await exportToZip(project);
      final zipFile = XFile(zipPath);

      await Share.shareXFiles(
        [zipFile],
        text: 'Projet ${project.name} généré avec Stream AI',
        subject: project.name,
      );

      _logger.info('Project shared: ${project.name}');
    } catch (e) {
      _logger.error('Error sharing project: $e');
      rethrow;
    }
  }

  // Sauvegarder un projet dans un dossier
  Future<String> saveProjectToFolder(ProjectModel project) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final projectsDir = Directory('${directory.path}/projects/${project.id}');

      if (!await projectsDir.exists()) {
        await projectsDir.create(recursive: true);
      }

      // Sauvegarder chaque fichier
      for (final file in project.files) {
        final fileDir = Directory('${projectsDir.path}/${file.path}').parent;
        if (!await fileDir.exists()) {
          await fileDir.create(recursive: true);
        }

        final filePath = '${projectsDir.path}/${file.path}';
        final fileObj = File(filePath);
        await fileObj.writeAsString(file.content);
      }

      // Sauvegarder le README
      final readmeContent = _generateReadme(project);
      final readmeFile = File('${projectsDir.path}/README.md');
      await readmeFile.writeAsString(readmeContent);

      _logger.info('Project saved to folder: ${projectsDir.path}');
      return projectsDir.path;
    } catch (e) {
      _logger.error('Error saving project to folder: $e');
      rethrow;
    }
  }

  // Générer un README pour le projet
  String _generateReadme(ProjectModel project) {
    final buffer = StringBuffer();

    buffer.writeln('# ${project.name}');
    buffer.writeln();
    buffer.writeln(project.description);
    buffer.writeln();
    buffer.writeln('## Structure du Projet');
    buffer.writeln();
    buffer.writeln('```');

    for (final file in project.files) {
      buffer.writeln(file.path);
    }

    buffer.writeln('```');
    buffer.writeln();
    buffer.writeln('## Fichiers');
    buffer.writeln();

    for (final file in project.files) {
      buffer.writeln('- `${file.path}` - ${file.language}');
    }

    buffer.writeln();
    buffer.writeln('## Statistiques');
    buffer.writeln();
    buffer.writeln('- **Nombre de fichiers:** ${project.files.length}');
    buffer.writeln('- **Lignes de code:** ${project.totalLines}');
    buffer.writeln('- **Langages:** ${project.languages.join(', ')}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('Généré avec [Stream AI](https://stream-ai.app)');

    return buffer.toString();
  }

  // Créer un projet à partir d'une réponse JSON
  Future<ProjectModel> createProjectFromJson(
    Map<String, dynamic> json,
    String userId,
  ) async {
    try {
      final files = (json['files'] as List)
          .map((f) => ProjectFile(
                name: f['name'] as String,
                path: f['path'] as String,
                content: f['content'] as String,
                language: f['language'] as String,
              ))
          .toList();

      return ProjectModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        name: json['name'] as String,
        description: json['description'] as String,
        files: files,
        projectType: json['project_type'] ?? 'generic',
        createdAt: DateTime.now(),
        metadata: {
          'instructions': json['instructions'],
          'generated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      _logger.error('Error creating project from JSON: $e');
      rethrow;
    }
  }

  // Lister les projets sauvegardés localement
  Future<List<Map<String, dynamic>>> listLocalProjects(String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final projectsDir = Directory('${directory.path}/projects');

      if (!await projectsDir.exists()) {
        return [];
      }

      final projects = <Map<String, dynamic>>[];

      await for (final entity in projectsDir.list()) {
        if (entity is Directory) {
          final readmeFile = File('${entity.path}/README.md');
          if (await readmeFile.exists()) {
            final stat = await entity.stat();
            projects.add({
              'path': entity.path,
              'name': entity.path.split('/').last,
              'modified': stat.modified,
            });
          }
        }
      }

      projects.sort((a, b) => (b['modified'] as DateTime)
          .compareTo(a['modified'] as DateTime));

      return projects;
    } catch (e) {
      _logger.error('Error listing local projects: $e');
      return [];
    }
  }

  // Supprimer un projet local
  Future<void> deleteLocalProject(String projectPath) async {
    try {
      final directory = Directory(projectPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        _logger.info('Local project deleted: $projectPath');
      }
    } catch (e) {
      _logger.error('Error deleting local project: $e');
      rethrow;
    }
  }
}
