class AppConstants {
  // Configuration Google OAuth
  static const String googleClientId = 
      '29679781298-32es8epvm18evpqb1b18njvugc59sie9.apps.googleusercontent.com';
  
  // Configuration Supabase
  static const String supabaseUrl = 'https://yagsdjbtldctjysfvsds.supabase.co';
  static const String supabaseAnonKey = 
      'sb_publishable_oGaSo-k461Cc4nTzk8abdA_NmktKi5v';
  
  // TES APIs - URLs corrigées
  static const String deliriusApiBaseUrl = 'https://api.delirius.store';  // .store, pas .ai !
  static const String zenApiBaseUrl = 'https://api.zenzxz.my.id';
  static const String eliasImageApiBaseUrl = 'https://eliasar-yt-api.vercel.app';
  static const String fluxImageApiBaseUrl = 'https://1yjs1yldj7.execute-api.us-east-1.amazonaws.com/default/ai_image';
  
  // Plus besoin de ces clés - APIs publiques
  // static const String deliriusApiKey = 'YOUR_DELIRIUS_API_KEY';
  // static const String fallbackApiBaseUrl = 'https://api.openai.com/v1';
  // static const String fallbackApiKey = 'YOUR_FALLBACK_API_KEY';
  
  // Configuration de l'application
  static const String appName = 'Stream AI';
  static const String appVersion = '1.0.0';
  static const String appPackage = 'com.precieux.stream';
  
  // Informations créateur
  static const String creatorName = 'Précieux Okitakoy';
  static const String creatorEmail = 'okitakoyprecieux@gmail.com';
  
  // Modes de chat
  static const String modeAsk = 'ask';
  static const String modeAgent = 'agent';
  
  // Langues supportées
  static const List<String> supportedLanguages = [
    'fr', 'en', 'es', 'de', 'it', 'pt', 'nl', 'ru', 'zh', 'ja', 'ar',
  ];
  
  // Durées de rétention
  static const int messageRetentionDays = 30;
  static const int dataCleanupIntervalHours = 24;
  
  // Limites
  static const int maxMessageLength = 4000;
  static const int maxImageSizeMB = 10;
  static const int maxChatHistory = 100;
  
  // Timeouts
  static const int apiTimeoutSeconds = 60;
  static const int connectionTimeoutSeconds = 10;
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int typingAnimationDelayMs = 50;
}