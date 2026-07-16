import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phone,
    this.nationality,
    this.educationLevel,
    this.currentSchool,
    this.gpa,
    this.targetCountries = const [],
    this.targetPrograms = const [],
    this.preferredLanguage = 'en',
    this.subscriptionTier = 'free',
    this.subscriptionExpiry,
    this.onboardingCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phone;
  final String? nationality;
  final String? educationLevel;
  final String? currentSchool;
  final double? gpa;
  final List<String> targetCountries;
  final List<String> targetPrograms;
  final String preferredLanguage;
  final String subscriptionTier;
  final DateTime? subscriptionExpiry;
  final bool onboardingCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPro =>
      subscriptionTier == 'pro' || subscriptionTier == 'premium';
  bool get isPremium => subscriptionTier == 'premium';
  bool get isFree => subscriptionTier == 'free';

  String get displayInitials {
    if (displayName == null || displayName!.isEmpty) {
      return email[0].toUpperCase();
    }
    final parts = displayName!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phone,
    String? nationality,
    String? educationLevel,
    String? currentSchool,
    double? gpa,
    List<String>? targetCountries,
    List<String>? targetPrograms,
    String? preferredLanguage,
    String? subscriptionTier,
    DateTime? subscriptionExpiry,
    bool? onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      educationLevel: educationLevel ?? this.educationLevel,
      currentSchool: currentSchool ?? this.currentSchool,
      gpa: gpa ?? this.gpa,
      targetCountries: targetCountries ?? this.targetCountries,
      targetPrograms: targetPrograms ?? this.targetPrograms,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, subscriptionTier];
}
