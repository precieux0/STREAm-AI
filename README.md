# Stream AI

Application de chat multi-IA avec génération d'images, créée avec Flutter.

## 🚀 Fonctionnalités

- **Authentification Google OAuth** - Connexion sécurisée via Google
- **Chat Multi-IA** - Intégration API Delirius avec système de fallback
- **Mode ASK** - Questions/réponses générales
- **Mode AGENT** - Génération de code et création de projets complets
- **Génération d'Images** - Création d'images à partir de descriptions
- **Export de Projets** - Téléchargement au format ZIP
- **Support Multi-langue** - Détection automatique de la langue

## 📋 Prérequis

- Flutter 3.16.0 ou supérieur
- Dart 3.0.0 ou supérieur
- Android SDK 33+ (Android 13+)
- Java 17

## 🛠️ Installation

### 1. Cloner le repository

```bash
git clone https://github.com/votre-repo/stream-ai.git
cd stream-ai
```

### 2. Exécuter le script de build

```bash
chmod +x build.sh
./build.sh
```

Ou manuellement :

```bash
# Installer les dépendances
flutter pub get

# Build l'APK
flutter build apk --release
```

### 3. Configuration

Créez un fichier `.env` à la racine du projet :

```env
SUPABASE_URL=votre_url_supabase
SUPABASE_ANON_KEY=votre_cle_supabase
GOOGLE_CLIENT_ID=votre_client_id_google
```

## 📁 Structure du Projet

```
stream_ai/
├── lib/
│   ├── models/          # Modèles de données
│   ├── services/        # Services (Auth, Chat, Supabase)
│   ├── viewmodels/      # ViewModels (Riverpod)
│   ├── views/           # Écrans de l'application
│   ├── widgets/         # Widgets réutilisables
│   └── utils/           # Utilitaires et constantes
├── android/             # Configuration Android
├── assets/              # Ressources (images, fonts)
├── test/                # Tests
└── build.sh             # Script de build
```

## 🏗️ Architecture

L'application suit l'architecture **MVVM** (Model-View-ViewModel) avec :

- **Flutter Riverpod** pour la gestion d'état
- **Supabase** pour la base de données et l'authentification
- **Google Sign In** pour l'authentification OAuth
- **Dio** pour les requêtes HTTP

## 🔧 Configuration Supabase

### Tables requises :

```sql
-- Table utilisateurs
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  photo_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  preferences JSONB DEFAULT '{}'::jsonb
);

-- Table messages
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_user BOOLEAN DEFAULT true,
  mode TEXT DEFAULT 'ask',
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Table projets
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  files JSONB DEFAULT '[]'::jsonb,
  project_type TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb
);

-- Table images générées
CREATE TABLE generated_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  prompt TEXT NOT NULL,
  image_url TEXT,
  local_path TEXT,
  style TEXT,
  size TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb
);
```

## 🚀 Déploiement

### GitHub Actions

Le workflow CI/CD est configuré pour :
- Analyser le code
- Exécuter les tests
- Builder l'APK et l'App Bundle
- Créer des releases automatiques

### Commandes de build

```bash
# Build APK debug
flutter build apk

# Build APK release
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Build iOS
flutter build ios --release
```

## 📝 Scripts disponibles

| Commande | Description |
|----------|-------------|
| `./build.sh` | Build complet |
| `./build.sh check` | Vérifier les prérequis |
| `./build.sh setup` | Configurer le projet |
| `./build.sh build` | Build APK uniquement |
| `./build.sh bundle` | Build App Bundle |
| `./build.sh test` | Exécuter les tests |
| `./build.sh analyze` | Analyser le code |
| `./build.sh clean` | Nettoyer le projet |

## 🤝 Contribution

1. Fork le projet
2. Créez une branche (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👤 Créateur

**Précieux Okitakoy**
- Email: okitakoyprecieux@gmail.com

---

<p align="center">Made with ❤️ using Flutter</p>
