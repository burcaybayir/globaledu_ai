class RouteNames {
  RouteNames._();

  // ─── Root ───
  static const String splash = 'splash';
  static const String splashPath = '/';

  // ─── Auth ───
  static const String login = 'login';
  static const String loginPath = '/login';
  static const String register = 'register';
  static const String registerPath = '/register';
  static const String forgotPassword = 'forgot-password';
  static const String forgotPasswordPath = '/forgot-password';
  static const String verifyEmail = 'verify-email';
  static const String verifyEmailPath = '/verify-email';

  // ─── Onboarding ───
  static const String welcome = 'welcome';
  static const String welcomePath = '/welcome';
  static const String profileSetup = 'profile-setup';
  static const String profileSetupPath = '/profile-setup';
  static const String countrySelection = 'country-selection';
  static const String countrySelectionPath = '/country-selection';
  static const String educationLevel = 'education-level';
  static const String educationLevelPath = '/education-level';
  static const String interests = 'interests';
  static const String interestsPath = '/interests';

  // ─── Main Shell ───
  static const String shell = 'shell';
  static const String shellPath = '/app';

  // ─── Home ───
  static const String home = 'home';
  static const String homePath = 'home';
  static const String notifications = 'notifications';
  static const String notificationsPath = 'notifications';

  // ─── Universities ───
  static const String universities = 'universities';
  static const String universitiesPath = 'universities';
  static const String universityDetail = 'university-detail';
  static const String universityDetailPath = 'universities/:id';
  static const String compare = 'compare';
  static const String comparePath = 'universities/compare';
  static const String recommendationInput = 'recommendation-input';
  static const String recommendationInputPath = 'universities/recommend';
  static const String recommendations = 'recommendations';
  static const String recommendationsPath = 'universities/recommendations';

  // ─── AI Assistant ───
  static const String aiChat = 'ai-chat';
  static const String aiChatPath = 'ai-chat';
  static const String conversationList = 'conversations';
  static const String conversationListPath = 'ai-chat/conversations';
  static const String conversationDetail = 'conversation-detail';
  static const String conversationDetailPath = 'ai-chat/conversations/:id';

  // ─── Applications ───
  static const String applications = 'applications';
  static const String applicationsPath = 'applications';
  static const String applicationDetail = 'application-detail';
  static const String applicationDetailPath = 'applications/:id';
  static const String createApplication = 'create-application';
  static const String createApplicationPath = 'applications/create';

  // ─── Documents ───
  static const String documents = 'documents';
  static const String documentsPath = 'documents';
  static const String documentPreview = 'document-preview';
  static const String documentPreviewPath = 'documents/:id';
  static const String aiReview = 'ai-review';
  static const String aiReviewPath = 'documents/:id/review';

  // ─── Visa ───
  static const String visaGuide = 'visa-guide';
  static const String visaGuidePath = 'visa';
  static const String visaChecklist = 'visa-checklist';
  static const String visaChecklistPath = 'visa/:country';
  static const String interviewPrep = 'interview-prep';
  static const String interviewPrepPath = 'visa/:country/interview';

  // ─── Scholarships ───
  static const String scholarships = 'scholarships';
  static const String scholarshipsPath = 'scholarships';
  static const String scholarshipDetail = 'scholarship-detail';
  static const String scholarshipDetailPath = 'scholarships/:id';

  // ─── Profile ───
  static const String profile = 'profile';
  static const String profilePath = 'profile';
  static const String editProfile = 'edit-profile';
  static const String editProfilePath = 'profile/edit';
  static const String settings = 'settings';
  static const String settingsPath = 'profile/settings';

  // ─── Subscription ───
  static const String paywall = 'paywall';
  static const String paywallPath = '/paywall';
  static const String subscription = 'subscription';
  static const String subscriptionPath = '/subscription';
}
