# Configuration de Stream AI

Ce document détaille la configuration nécessaire pour faire fonctionner Stream AI.

## 🔑 Clés API Requises

### 1. Supabase

**Configuration existante :**
- URL : `https://yagsdjbtldctjysfvsds.supabase.co`
- Clé publique : `sb_publishable_oGaSo-k461Cc4nTzk8abdA_NmktKi5v`

**Tables à créer :**

```sql
-- Activer l'extension UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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

-- Index pour optimiser les requêtes
CREATE INDEX idx_messages_user_id ON messages(user_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_images_user_id ON generated_images(user_id);

-- Politiques RLS (Row Level Security)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE generated_images ENABLE ROW LEVEL SECURITY;

-- Politique : Les utilisateurs peuvent voir uniquement leurs propres données
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own data" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own messages" ON messages
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own messages" ON messages
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own messages" ON messages
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own projects" ON projects
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own projects" ON projects
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own projects" ON projects
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own images" ON generated_images
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own images" ON generated_images
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own images" ON generated_images
  FOR DELETE USING (auth.uid() = user_id);
```

### 2. Google OAuth

**Configuration existante :**
- Client ID : `29679781298-32es8epvm18evpqb1b18njvugc59sie9.apps.googleusercontent.com`
- SHA-1 : `9B:CD:7C:00:BB:CF:94:E7:3C:69:57:F4:BD:33:6A:FF:31:E9:FA:B2`

**Configuration dans Google Cloud Console :**

1. Accédez à [Google Cloud Console](https://console.cloud.google.com/)
2. Sélectionnez votre projet
3. Allez dans "APIs & Services" > "Credentials"
4. Vérifiez que l'OAuth 2.0 Client ID est configuré
5. Ajoutez les URI de redirection :
   - `com.googleusercontent.apps.29679781298-32es8epvm18evpqb1b18njvugc59sie9:/`

### 3. API Delirius (IA Principale)

**À configurer :**

1. Créez un compte sur [Delirius API](https://api.delirius.ai)
2. Obtenez votre clé API
3. Mettez à jour le fichier `lib/utils/constants.dart` :

```dart
static const String deliriusApiKey = 'VOTRE_CLE_API_DELIRIUS';
```

### 4. API Fallback (Optionnel)

**Configuration OpenAI (recommandé) :**

1. Créez un compte sur [OpenAI](https://platform.openai.com)
2. Générez une clé API
3. Mettez à jour le fichier `lib/utils/constants.dart` :

```dart
static const String fallbackApiKey = 'VOTRE_CLE_API_OPENAI';
```

### 5. API de Génération d'Images (Optionnel)

**Configuration Stability AI :**

1. Créez un compte sur [Stability AI](https://stability.ai)
2. Obtenez votre clé API
3. Mettez à jour le fichier `lib/services/image_generation_service.dart` :

```dart
_apiKey = 'VOTRE_CLE_API_STABILITY';
```

## 🔧 Configuration Flutter

### Fichier `local.properties`

Créez ce fichier dans le dossier `android/` :

```properties
flutter.sdk=/chemin/vers/flutter
flutter.versionName=1.0.0
flutter.versionCode=1
flutter.buildMode=release
```

### Configuration de la signature (Release)

Créez le fichier `android/key.properties` :

```properties
storePassword=votre_mot_de_passe
keyPassword=votre_mot_de_passe
keyAlias=stream_ai
storeFile=../keystore.jks
```

## 🚀 Déploiement

### Build de production

```bash
# Build APK
flutter build apk --release

# Build App Bundle (pour Google Play)
flutter build appbundle --release
```

### Vérification avant déploiement

- [ ] Toutes les clés API sont configurées
- [ ] Les tables Supabase sont créées
- [ ] Les politiques RLS sont activées
- [ ] La signature est configurée
- [ ] Les tests passent
- [ ] L'analyse statique ne montre pas d'erreurs

## 📊 Monitoring

### Supabase

- Limite de stockage : 1 GB
- Durée de rétention des messages : 30 jours
- Nettoyage automatique configuré

### Logs

Les logs sont gérés via la classe `AppLogger` et affichés dans la console de débogage.

## 🔒 Sécurité

- ✅ Authentification OAuth 2.0 avec Google
- ✅ Row Level Security (RLS) sur toutes les tables
- ✅ Aucune donnée stockée localement en clair
- ✅ Communications HTTPS uniquement
- ✅ Validation des entrées utilisateur

## 🆘 Support

En cas de problème :

1. Vérifiez les logs dans la console
2. Contrôlez la configuration des clés API
3. Vérifiez la connexion à Supabase
4. Consultez les issues sur GitHub

Contact : okitakoyprecieux@gmail.com
