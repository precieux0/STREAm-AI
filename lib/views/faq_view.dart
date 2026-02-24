import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class FAQView extends StatelessWidget {
  const FAQView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // En-tête
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),

          // Contenu FAQ
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Section À propos
                _buildSection(
                  context,
                  title: 'À propos',
                  icon: Icons.info_outline,
                  children: [
                    _buildInfoCard(
                      context,
                      title: 'Stream AI',
                      subtitle: 'Version ${AppConstants.appVersion}',
                      description:
                          'Stream AI est votre assistant intelligent multi-fonctions. '
                          'Chattez avec une IA avancée, générez du code, créez des projets complets '
                          'et produisez des images uniques à partir de descriptions textuelles.',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Section Créateur
                _buildSection(
                  context,
                  title: 'Le Créateur',
                  icon: Icons.person_outline,
                  children: [
                    _buildCreatorCard(context),
                  ],
                ),

                const SizedBox(height: 24),

                // Section FAQ
                _buildSection(
                  context,
                  title: 'Questions Fréquentes',
                  icon: Icons.help_outline,
                  children: [
                    _buildFAQItem(
                      context,
                      question: 'Comment fonctionne le mode Agent ?',
                      answer:
                          'Le mode Agent est spécialement conçu pour la programmation. '
                          'Il peut générer du code dans n\'importe quel langage, créer des projets complets '
                          'avec structure de fichiers, et analyser votre code pour suggérer des améliorations.',
                    ),
                    _buildFAQItem(
                      context,
                      question: 'Mes données sont-elles sécurisées ?',
                      answer:
                          'Oui, toutes vos données sont stockées de manière sécurisée sur Supabase '
                          'avec chiffrement. Les messages sont conservés pendant ${AppConstants.messageRetentionDays} jours '
                          'puis automatiquement supprimés.',
                    ),
                    _buildFAQItem(
                      context,
                      question: 'Puis-je exporter mes projets ?',
                      answer:
                          'Absolument ! Vous pouvez exporter vos projets au format ZIP '
                          'pour les télécharger ou les partager facilement.',
                    ),
                    _buildFAQItem(
                      context,
                      question: 'Quelles langues sont supportées ?',
                      answer:
                          'Stream AI détecte automatiquement la langue de vos messages '
                          'et répond dans la même langue. Nous supportons le français, anglais, '
                          'espagnol, allemand, italien, portugais et bien d\'autres.',
                    ),
                    _buildFAQItem(
                      context,
                      question: 'Comment fonctionne la génération d\'images ?',
                      answer:
                          'Décrivez simplement l\'image que vous souhaitez créer, choisissez un style '
                          'et une taille, et notre IA générera une image unique basée sur votre description.',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Section Contact
                _buildSection(
                  context,
                  title: 'Contact',
                  icon: Icons.mail_outline,
                  children: [
                    _buildContactCard(context),
                  ],
                ),

                const SizedBox(height: 24),

                // Section Technologies
                _buildSection(
                  context,
                  title: 'Technologies Utilisées',
                  icon: Icons.code,
                  children: [
                    _buildTechChips(context),
                  ],
                ),

                const SizedBox(height: 32),

                // Footer
                Center(
                  child: Text(
                    '© 2024 Stream AI - Tous droits réservés',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            'FAQ & Informations',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tout ce que vous devez savoir sur Stream AI',
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

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(description),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.creatorName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Développeur & Créateur',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => _sendEmail(),
                  icon: const Icon(Icons.mail),
                  label: const Text('Contacter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.8),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.email, color: AppTheme.primaryColor),
            title: const Text('Email'),
            subtitle: Text(AppConstants.creatorEmail),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: AppConstants.creatorEmail),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email copié')),
                );
              },
            ),
            onTap: () => _sendEmail(),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChips(BuildContext context) {
    final technologies = [
      {'name': 'Flutter', 'icon': '📱'},
      {'name': 'Dart', 'icon': '🎯'},
      {'name': 'Supabase', 'icon': '⚡'},
      {'name': 'Google OAuth', 'icon': '🔐'},
      {'name': 'AI/ML', 'icon': '🤖'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: technologies.map((tech) {
        return Chip(
          avatar: Text(tech['icon']!),
          label: Text(tech['name']!),
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        );
      }).toList(),
    );
  }

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.creatorEmail,
      queryParameters: {
        'subject': 'Contact Stream AI',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
