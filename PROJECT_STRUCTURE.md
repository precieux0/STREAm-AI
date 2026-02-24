# Structure du Projet Stream AI

## 📁 Arborescence Complète

```
stream_ai/
├── 📄 .github/
│   └── workflows/
│       └── build.yml              # CI/CD GitHub Actions
│
├── 📄 android/
│   ├── app/
│   │   ├── build.gradle           # Configuration build Android
│   │   └── src/
│   │       └── main/
│   │           ├── AndroidManifest.xml
│   │           ├── kotlin/
│   │           │   └── com/
│   │           │       └── precieux/
│   │           │           └── stream/
│   │           │               └── MainActivity.kt
│   │           └── res/
│   │               ├── drawable/
│   │               │   └── launch_background.xml
│   │               └── values/
│   │                   └── styles.xml
│   ├── build.gradle
│   └── settings.gradle
│
├── 📄 assets/
│   ├── fonts/                     # Polices personnalisées
│   ├── icons/                     # Icônes de l'application
│   └── images/                    # Images statiques
│
├── 📄 fastlane/
│   ├── metadata/
│   │   └── android/
│   │       └── en-US/
│   │           ├── full_description.txt
│   │           ├── short_description.txt
│   │           └── title.txt
│   ├── Appfile
│   └── Fastfile                   # Configuration Fastlane
│
├── 📄 lib/
│   ├── main.dart                  # Point d'entrée
│   │
│   ├── models/                    # Modèles de données
│   │   ├── generated_image_model.dart
│   │   ├── message_model.dart
│   │   ├── models.dart
│   │   ├── project_model.dart
│   │   └── user_model.dart
│   │
│   ├── services/                  # Services métier
│   │   ├── auth_service.dart      # Authentification Google
│   │   ├── chat_service.dart      # API Delirius + fallback
│   │   ├── image_generation_service.dart
│   │   ├── project_export_service.dart
│   │   ├── services.dart
│   │   └── supabase_service.dart  # Gestion données
│   │
│   ├── utils/                     # Utilitaires
│   │   ├── constants.dart         # Constantes & configuration
│   │   ├── helpers.dart           # Fonctions utilitaires
│   │   ├── logger.dart            # Système de logs
│   │   ├── theme.dart             # Thèmes clair/sombre
│   │   └── utils.dart
│   │
│   ├── viewmodels/                # ViewModels (Riverpod)
│   │   ├── auth_viewmodel.dart
│   │   ├── chat_viewmodel.dart
│   │   ├── image_generation_viewmodel.dart
│   │   └── viewmodels.dart
│   │
│   ├── views/                     # Écrans de l'application
│   │   ├── chat_view.dart         # Interface chat (ASK/AGENT)
│   │   ├── faq_view.dart          # FAQ & informations
│   │   ├── home_view.dart         # Navigation principale
│   │   ├── image_generation_view.dart
│   │   ├── login_view.dart        # Connexion Google
│   │   ├── profile_view.dart      # Profil utilisateur
│   │   ├── projects_view.dart     # Gestion des projets
│   │   ├── splash_view.dart       # Écran de démarrage
│   │   └── views.dart
│   │
│   └── widgets/                   # Widgets réutilisables
│       ├── message_bubble.dart    # Bulles de message
│       ├── mode_selector.dart     # Sélecteur ASK/AGENT
│       ├── typing_indicator.dart  # Indicateur de frappe
│       └── widgets.dart
│
├── 📄 test/                       # Tests unitaires
│   ├── models_test.dart
│   └── widget_test.dart
│
├── 📄 analysis_options.yaml       # Configuration analyse Dart
├── 📄 build.sh                    # Script de build automatisé
├── 📄 CONFIGURATION.md            # Guide de configuration
├── 📄 LICENSE                     # Licence MIT
├── 📄 PROJECT_STRUCTURE.md        # Ce fichier
├── 📄 pubspec.yaml                # Dépendances Flutter
└── 📄 README.md                   # Documentation principale
```

## 📊 Statistiques

- **Nombre total de fichiers** : 50+
- **Fichiers Dart** : 35
- **Fichiers de configuration** : 15
- **Lignes de code estimées** : 5000+

## 🏗️ Architecture

### Pattern : MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────────────────────────────┐
│                         VIEWS                               │
│  (Splash, Login, Home, Chat, Projects, Images, FAQ)        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      VIEWMODELS                             │
│  (AuthViewModel, ChatViewModel, ImageGenerationViewModel)  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       SERVICES                              │
│  (AuthService, ChatService, SupabaseService, etc.)         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        MODELS                               │
│  (UserModel, MessageModel, ProjectModel, etc.)             │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Technologies Utilisées

| Technologie | Usage |
|-------------|-------|
| Flutter 3.16+ | Framework UI |
| Dart 3.0+ | Langage de programmation |
| Riverpod | Gestion d'état |
| Supabase | Base de données & Auth |
| Google Sign In | Authentification OAuth |
| Dio | Requêtes HTTP |
| Flutter Animate | Animations |
| Google Fonts | Typographie |

## 📱 Fonctionnalités par Écran

### SplashView
- Animation de logo
- Vérification de session
- Redirection automatique

### LoginView
- Connexion Google OAuth
- Gestion des erreurs
- Interface moderne

### HomeView
- Navigation bottom bar
- 4 sections principales
- Accès rapide profil

### ChatView
- Mode ASK (questions/réponses)
- Mode AGENT (code/projets)
- Historique des messages
- Support code syntax highlighting

### ProjectsView
- Création de projets
- Export ZIP
- Partage
- Visualisation fichiers

### ImageGenerationView
- Génération par prompt
- Sélection style/taille
- Galerie personnelle
- Téléchargement

### FAQView
- Informations application
- Contact créateur
- Questions fréquentes
- Technologies utilisées

### ProfileView
- Informations utilisateur
- Statistiques
- Préférences
- Déconnexion

## 🚀 Workflows CI/CD

### GitHub Actions (`.github/workflows/build.yml`)

1. **analyze-and-test**
   - Analyse statique du code
   - Exécution des tests
   - Upload couverture

2. **build-apk**
   - Build APK release
   - Upload artefacts

3. **build-appbundle**
   - Build AAB (Play Store)
   - Upload artefacts

4. **build-ios**
   - Build iOS (macOS only)
   - Upload artefacts

5. **release**
   - Création release GitHub
   - Upload APK/AAB

## 📝 Scripts Disponibles

### build.sh

```bash
./build.sh check      # Vérifier prérequis
./build.sh setup      # Configurer projet
./build.sh deps       # Installer dépendances
./build.sh build      # Build APK
./build.sh bundle     # Build App Bundle
./build.sh test       # Exécuter tests
./build.sh analyze    # Analyser code
./build.sh clean      # Nettoyer projet
./build.sh            # Build complet
```

## 🔐 Configuration Requise

### Clés API
- Supabase URL & Anon Key ✅
- Google Client ID ✅
- API Delirius Key (à configurer)
- API Fallback Key (optionnel)
- API Image Generation (optionnel)

### Tables Supabase
- `users` - Utilisateurs
- `messages` - Messages chat
- `projects` - Projets générés
- `generated_images` - Images créées

## 📦 Dépendances Principales

```yaml
dependencies:
  # UI
  flutter_animate: ^4.3.0
  google_fonts: ^6.1.0
  
  # Auth
  google_sign_in: ^6.1.6
  
  # Backend
  supabase_flutter: ^2.0.0
  
  # HTTP
  dio: ^5.4.0
  
  # State
  flutter_riverpod: ^2.4.9
  
  # Storage
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  
  # Files
  archive: ^3.4.9
  
  # Utils
  intl: ^0.18.1
  uuid: ^4.2.1
```

---

**Version** : 1.0.0  
**Créateur** : Précieux Okitakoy  
**Date** : 2024
