class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'GlobalEdu AI';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Cache
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int maxCacheSize = 100;

  // AI Chat
  static const int freeMessagesPerDay = 10;
  static const int proMessagesPerDay = 100;
  static const int maxConversationHistory = 50;
  static const int maxMessageLength = 4000;

  // Documents
  static const int maxFileSizeMB = 25;
  static const List<String> allowedFileTypes = [
    'pdf',
    'doc',
    'docx',
    'jpg',
    'jpeg',
    'png',
  ];

  // Storage Limits (in bytes)
  static const int freeStorageLimit = 100 * 1024 * 1024; // 100MB
  static const int proStorageLimit = 1024 * 1024 * 1024; // 1GB
  static const int premiumStorageLimit = 10 * 1024 * 1024 * 1024; // 10GB

  // Application Limits
  static const int freeApplicationLimit = 2;
  static const int proApplicationLimit = 10;

  // Document Review Limits
  static const int proDocReviewLimit = 5;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 300);

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration typeDebounce = Duration(milliseconds: 300);

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
