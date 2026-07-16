import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:globaledu_ai/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.phone,
    super.nationality,
    super.educationLevel,
    super.currentSchool,
    super.gpa,
    super.targetCountries,
    super.targetPrograms,
    super.preferredLanguage,
    super.subscriptionTier,
    super.subscriptionExpiry,
    super.onboardingCompleted,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phone: data['phone'] as String?,
      nationality: data['nationality'] as String?,
      educationLevel: data['educationLevel'] as String?,
      currentSchool: data['currentSchool'] as String?,
      gpa: (data['gpa'] as num?)?.toDouble(),
      targetCountries: List<String>.from(
        data['targetCountries'] as List? ?? [],
      ),
      targetPrograms: List<String>.from(
        data['targetPrograms'] as List? ?? [],
      ),
      preferredLanguage: data['preferredLanguage'] as String? ?? 'en',
      subscriptionTier: data['subscriptionTier'] as String? ?? 'free',
      subscriptionExpiry: (data['subscriptionExpiry'] as Timestamp?)?.toDate(),
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      phone: entity.phone,
      nationality: entity.nationality,
      educationLevel: entity.educationLevel,
      currentSchool: entity.currentSchool,
      gpa: entity.gpa,
      targetCountries: entity.targetCountries,
      targetPrograms: entity.targetPrograms,
      preferredLanguage: entity.preferredLanguage,
      subscriptionTier: entity.subscriptionTier,
      subscriptionExpiry: entity.subscriptionExpiry,
      onboardingCompleted: entity.onboardingCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phone': phone,
      'nationality': nationality,
      'educationLevel': educationLevel,
      'currentSchool': currentSchool,
      'gpa': gpa,
      'targetCountries': targetCountries,
      'targetPrograms': targetPrograms,
      'preferredLanguage': preferredLanguage,
      'subscriptionTier': subscriptionTier,
      'subscriptionExpiry': subscriptionExpiry != null
          ? Timestamp.fromDate(subscriptionExpiry!)
          : null,
      'onboardingCompleted': onboardingCompleted,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
