import 'package:globaledu_ai/core/constants/app_constants.dart';

class AppConfig {
  AppConfig._();

  static const String defaultLocale = 'en';
  static const String fallbackLocale = 'en';

  static const List<String> supportedLocales = ['en', 'tr'];

  static const List<String> supportedCountries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Germany',
    'Australia',
    'France',
    'Netherlands',
    'Sweden',
    'Japan',
    'South Korea',
    'Italy',
    'Spain',
    'Switzerland',
    'Austria',
    'Ireland',
    'New Zealand',
    'Norway',
    'Denmark',
    'Finland',
    'Belgium',
  ];

  static const List<String> educationLevels = [
    'High School',
    'Associate Degree',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD / Doctorate',
    'Language Course',
    'Summer School',
    'Certificate Program',
  ];

  static const List<String> studyFields = [
    'Computer Science & IT',
    'Engineering',
    'Business & Management',
    'Medicine & Health',
    'Law',
    'Arts & Design',
    'Social Sciences',
    'Natural Sciences',
    'Mathematics & Statistics',
    'Education',
    'Architecture',
    'Media & Communication',
    'Languages & Literature',
    'Environmental Studies',
    'Psychology',
    'Economics',
    'Political Science',
    'Music & Performing Arts',
  ];

  static const List<String> applicationStatuses = [
    'Preparing',
    'Submitted',
    'Under Review',
    'Interview Scheduled',
    'Conditional Offer',
    'Unconditional Offer',
    'Accepted',
    'Rejected',
    'Withdrawn',
  ];

  static const List<String> documentTypes = [
    'Transcript',
    'Diploma',
    'CV / Resume',
    'Motivation Letter',
    'Recommendation Letter',
    'Language Certificate',
    'Passport Copy',
    'Financial Statement',
    'Portfolio',
    'Research Proposal',
    'Other',
  ];

  static Duration get connectionTimeout => AppConstants.connectionTimeout;
  static Duration get receiveTimeout => AppConstants.receiveTimeout;
}
