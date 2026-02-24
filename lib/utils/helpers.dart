import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class Helpers {
  // Formater une date relative
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} min';
      }
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  // Formater une heure
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Formater une date complète
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Tronquer un texte
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Compter les mots
  static int countWords(String text) {
    return text.trim().split(RegExp(r'\s+')).length;
  }

  // Compter les caractères
  static int countCharacters(String text) {
    return text.length;
  }

  // Vérifier si un email est valide
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Vérifier si un URL est valide
  static bool isValidUrl(String url) {
    return RegExp(r'^(http|https)://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(/\S*)?$')
        .hasMatch(url);
  }

  // Obtenir les initiales d'un nom
  static String getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  // Générer une couleur à partir d'une chaîne
  static Color generateColor(String text) {
    int hash = 0;
    for (var i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }

    final hue = (hash.abs() % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
  }

  // Détecter si le texte contient du code
  static bool containsCode(String text) {
    final codePatterns = [
      r'```',
      r'<code>',
      r'function\s+\w+',
      r'class\s+\w+',
      r'import\s+',
      r'const\s+\w+',
      r'let\s+\w+',
      r'var\s+\w+',
      r'def\s+\w+',
      r'public\s+static',
      r'#include',
      r'<?php',
    ];

    for (final pattern in codePatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  // Extraire les blocs de code d'un texte
  static List<Map<String, String>> extractCodeBlocks(String text) {
    final blocks = <Map<String, String>>[];
    final regex = RegExp(r'```(\w+)?\n([\s\S]*?)```');

    for (final match in regex.allMatches(text)) {
      blocks.add({
        'language': match.group(1) ?? 'text',
        'code': match.group(2)?.trim() ?? '',
      });
    }

    return blocks;
  }

  // Nettoyer le texte des balises Markdown
  static String stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'\*'), '')
        .replaceAll(RegExp(r'__'), '')
        .replaceAll(RegExp(r'_'), '')
        .replaceAll(RegExp(r'`'), '')
        .replaceAll(RegExp(r'#+\s*'), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1')
        .replaceAll(RegExp(r'!\[[^\]]*\]\([^\)]+\)'), '');
  }

  // Obtenir l'icône pour un langage de programmation
  static IconData getLanguageIcon(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
      case 'flutter':
        return Icons.flutter_dash;
      case 'javascript':
      case 'js':
        return Icons.javascript;
      case 'typescript':
      case 'ts':
        return Icons.code;
      case 'python':
      case 'py':
        return Icons.code;
      case 'java':
        return Icons.code;
      case 'kotlin':
        return Icons.code;
      case 'swift':
        return Icons.apple;
      case 'html':
        return Icons.html;
      case 'css':
        return Icons.css;
      case 'json':
        return Icons.data_object;
      case 'sql':
        return Icons.storage;
      case 'markdown':
      case 'md':
        return Icons.description;
      default:
        return Icons.code;
    }
  }

  // Obtenir la couleur pour un langage
  static Color getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
        return const Color(0xFF00B4AB);
      case 'javascript':
      case 'js':
        return const Color(0xFFF7DF1E);
      case 'typescript':
      case 'ts':
        return const Color(0xFF3178C6);
      case 'python':
      case 'py':
        return const Color(0xFF3776AB);
      case 'java':
        return const Color(0xFF007396);
      case 'kotlin':
        return const Color(0xFF7F52FF);
      case 'swift':
        return const Color(0xFFF05138);
      case 'html':
        return const Color(0xFFE34F26);
      case 'css':
        return const Color(0xFF1572B6);
      case 'json':
        return const Color(0xFF292929);
      case 'sql':
        return const Color(0xFF336791);
      default:
        return Colors.grey;
    }
  }

  // Valider la longueur d'un message
  static bool isValidMessageLength(String message) {
    return message.length <= AppConstants.maxMessageLength &&
        message.trim().isNotEmpty;
  }

  // Obtenir le nom d'affichage d'une langue
  static String getLanguageDisplayName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'nl':
        return 'Nederlands';
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'ar':
        return 'العربية';
      default:
        return code.toUpperCase();
    }
  }

  // Obtenir le drapeau d'une langue
  static String getLanguageFlag(String code) {
    switch (code) {
      case 'fr':
        return '🇫🇷';
      case 'en':
        return '🇬🇧';
      case 'es':
        return '🇪🇸';
      case 'de':
        return '🇩🇪';
      case 'it':
        return '🇮🇹';
      case 'pt':
        return '🇵🇹';
      case 'nl':
        return '🇳🇱';
      case 'ru':
        return '🇷🇺';
      case 'zh':
        return '🇨🇳';
      case 'ja':
        return '🇯🇵';
      case 'ar':
        return '🇸🇦';
      default:
        return '🌐';
    }
  }
}
