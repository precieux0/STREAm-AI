#!/bin/bash

# =============================================================================
# Script d'installation et de build pour Stream AI
# =============================================================================
# Ce script reproduit l'intégralité du projet Flutter Stream AI
# =============================================================================

set -e

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
PROJECT_NAME="stream_ai"
PROJECT_DIR="$(pwd)"
FLUTTER_VERSION="3.16.0"

# =============================================================================
# Fonctions utilitaires
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# Vérification des prérequis
# =============================================================================

check_prerequisites() {
    log_info "Vérification des prérequis..."

    # Vérifier Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter n'est pas installé. Veuillez installer Flutter $FLUTTER_VERSION"
        exit 1
    fi

    FLUTTER_INSTALLED_VERSION=$(flutter --version | head -n 1 | awk '{print $2}')
    log_info "Flutter version: $FLUTTER_INSTALLED_VERSION"

    # Vérifier Dart
    if ! command -v dart &> /dev/null; then
        log_error "Dart n'est pas installé"
        exit 1
    fi

    # Vérifier Git
    if ! command -v git &> /dev/null; then
        log_error "Git n'est pas installé"
        exit 1
    fi

    # Vérifier Java
    if ! command -v java &> /dev/null; then
        log_warning "Java n'est pas installé. Nécessaire pour Android builds"
    fi

    log_success "Prérequis vérifiés"
}

# =============================================================================
# Création de la structure du projet
# =============================================================================

create_project_structure() {
    log_info "Création de la structure du projet..."

    # Créer les répertoires
    mkdir -p lib/{models,services,viewmodels,views,widgets,utils}
    mkdir -p android/app/src/main/kotlin/com/precieux/stream
    mkdir -p assets/{images,icons,fonts}
    mkdir -p test
    mkdir -p .github/workflows

    log_success "Structure du projet créée"
}

# =============================================================================
# Génération des fichiers de configuration
# =============================================================================

generate_pubspec() {
    log_info "Génération du pubspec.yaml..."

    cat > pubspec.yaml << 'EOF'
name: stream_ai
description: Stream AI - Application de chat multi-IA avec génération d'images
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # UI
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  shimmer: ^3.0.0
  flutter_animate: ^4.3.0
  
  # Authentification
  google_sign_in: ^6.1.6
  
  # Supabase
  supabase_flutter: ^2.0.0
  
  # HTTP & API
  dio: ^5.4.0
  http: ^1.1.0
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # Stockage local
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  
  # Gestion de fichiers
  archive: ^3.4.9
  file_picker: ^6.1.1
  
  # Images
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4
  
  # Utilitaires
  intl: ^0.18.1
  uuid: ^4.2.1
  logger: ^2.0.2
  
  # Langue
  langdetect: ^2.0.0
  
  # Permissions
  permission_handler: ^11.0.1
  
  # Partage
  share_plus: ^7.2.1
  
  # Téléchargement
  flutter_downloader: ^1.11.4
  
  # Génération d'images
  http_parser: ^4.0.2
  
  # URL Launcher
  url_launcher: ^6.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  mockito: ^5.4.4

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/
  
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
EOF

    log_success "pubspec.yaml généré"
}

# =============================================================================
# Installation des dépendances
# =============================================================================

install_dependencies() {
    log_info "Installation des dépendances Flutter..."

    flutter clean
    flutter pub get

    log_success "Dépendances installées"
}

# =============================================================================
# Build de l'application
# =============================================================================

build_apk() {
    log_info "Build de l'APK..."

    flutter build apk --release

    log_success "APK généré: build/app/outputs/flutter-apk/app-release.apk"
}

build_appbundle() {
    log_info "Build de l'App Bundle..."

    flutter build appbundle --release

    log_success "App Bundle généré: build/app/outputs/bundle/release/app-release.aab"
}

# =============================================================================
# Exécution des tests
# =============================================================================

run_tests() {
    log_info "Exécution des tests..."

    flutter test

    log_success "Tests terminés"
}

# =============================================================================
# Analyse du code
# =============================================================================

analyze_code() {
    log_info "Analyse du code..."

    flutter analyze

    log_success "Analyse terminée"
}

# =============================================================================
# Génération des icônes
# =============================================================================

generate_icons() {
    log_info "Génération des icônes..."

    # Créer les icônes par défaut si elles n'existent pas
    if [ ! -f "assets/icons/app_icon.png" ]; then
        log_warning "Icône personnalisée non trouvée, utilisation de l'icône par défaut"
    fi

    log_success "Icônes générées"
}

# =============================================================================
# Configuration de l'environnement
# =============================================================================

setup_environment() {
    log_info "Configuration de l'environnement..."

    # Créer le fichier .env s'il n'existe pas
    if [ ! -f ".env" ]; then
        cat > .env << 'EOF'
# Configuration Stream AI
SUPABASE_URL=https://yagsdjbtldctjysfvsds.supabase.co
SUPABASE_ANON_KEY=sb_publishable_oGaSo-k461Cc4nTzk8abdA_NmktKi5v
GOOGLE_CLIENT_ID=29679781298-32es8epvm18evpqb1b18njvugc59sie9.apps.googleusercontent.com
EOF
        log_info "Fichier .env créé"
    fi

    log_success "Environnement configuré"
}

# =============================================================================
# Fonction principale
# =============================================================================

main() {
    echo "========================================"
    echo "  Stream AI - Script de Build"
    echo "========================================"
    echo ""

    case "${1:-all}" in
        "check")
            check_prerequisites
            ;;
        "setup")
            check_prerequisites
            create_project_structure
            generate_pubspec
            setup_environment
            ;;
        "deps")
            install_dependencies
            ;;
        "build")
            check_prerequisites
            install_dependencies
            analyze_code
            build_apk
            ;;
        "bundle")
            check_prerequisites
            install_dependencies
            analyze_code
            build_appbundle
            ;;
        "test")
            run_tests
            ;;
        "analyze")
            analyze_code
            ;;
        "clean")
            flutter clean
            log_success "Projet nettoyé"
            ;;
        "all"|*)
            check_prerequisites
            create_project_structure
            generate_pubspec
            setup_environment
            install_dependencies
            analyze_code
            run_tests
            build_apk
            log_success "Build complet terminé avec succès !"
            ;;
    esac
}

# =============================================================================
# Affichage de l'aide
# =============================================================================

show_help() {
    cat << 'EOF'
Usage: ./build.sh [commande]

Commandes disponibles:
  check    - Vérifier les prérequis
  setup    - Configurer la structure du projet
  deps     - Installer les dépendances
  build    - Build l'APK (debug)
  bundle   - Build l'App Bundle (release)
  test     - Exécuter les tests
  analyze  - Analyser le code
  clean    - Nettoyer le projet
  all      - Exécuter toutes les étapes (par défaut)
  help     - Afficher cette aide

Exemples:
  ./build.sh           # Build complet
  ./build.sh check     # Vérifier les prérequis
  ./build.sh build     # Build uniquement l'APK
EOF
}

# =============================================================================
# Point d'entrée
# =============================================================================

if [ "$1" == "help" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    show_help
    exit 0
fi

main "$@"
