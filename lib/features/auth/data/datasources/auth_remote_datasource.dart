import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:globaledu_ai/core/constants/firebase_constants.dart';
import 'package:globaledu_ai/core/errors/exceptions.dart';
import 'package:globaledu_ai/core/utils/logger.dart';
import 'package:globaledu_ai/features/auth/data/models/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(FirebaseConstants.usersCollection);

  /// Sign in with email/password.
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _getUserModel(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign in failed', code: e.code);
    }
  }

  /// Sign up with email/password and create Firestore profile.
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(displayName);

      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _usersRef.doc(userModel.uid).set(userModel.toFirestore());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign up failed', code: e.code);
    }
  }

  /// Sign in with Google.
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(message: 'Google sign-in was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Create or update user in Firestore
      final docRef = _usersRef.doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
        await docRef.set(userModel.toFirestore());
        return userModel;
      }

      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Google sign-in failed',
        code: e.code,
      );
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Reset password.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: e.message ?? 'Password reset failed',
        code: e.code,
      );
    }
  }

  /// Get current user from Firestore.
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _getUserModel(user);
  }

  /// Auth state changes stream.
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _getUserModel(user);
    });
  }

  Future<UserModel> _getUserModel(User user) async {
    final doc = await _usersRef.doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }

    // Create a basic profile if it doesn't exist
    final model = UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );
    await _usersRef.doc(user.uid).set(model.toFirestore());
    return model;
  }
}
