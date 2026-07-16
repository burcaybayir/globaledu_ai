class FirebaseConstants {
  FirebaseConstants._();

  // Collection names
  static const String usersCollection = 'users';
  static const String conversationsCollection = 'conversations';
  static const String messagesCollection = 'messages';
  static const String universitiesCollection = 'universities';
  static const String applicationsCollection = 'applications';
  static const String documentsCollection = 'documents';
  static const String scholarshipsCollection = 'scholarships';
  static const String visaChecklistsCollection = 'visa_checklists';
  static const String notificationsCollection = 'notifications';
  static const String subscriptionsCollection = 'subscriptions';

  // Storage paths
  static const String avatarsPath = 'avatars';
  static const String documentsPath = 'documents';
  static const String universityLogosPath = 'university_logos';

  // Firestore field names (common)
  static const String fieldUserId = 'userId';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldIsActive = 'isActive';

  // FCM Topics
  static const String topicGeneral = 'general';
  static const String topicDeadlines = 'deadlines';
  static const String topicScholarships = 'scholarships';
  static const String topicNews = 'news';
}
