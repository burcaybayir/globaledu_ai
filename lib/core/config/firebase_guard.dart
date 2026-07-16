/// Global flag indicating whether Firebase was successfully initialized.
/// This avoids calling any Firebase API (including Firebase.apps)
/// which can throw web JS interop errors when not configured.
class FirebaseGuard {
  FirebaseGuard._();

  static bool _initialized = false;

  /// Mark Firebase as initialized. Call this after Firebase.initializeApp().
  static void markInitialized() {
    _initialized = true;
  }

  /// Returns `true` if Firebase has been initialized.
  static bool get isInitialized => _initialized;
}
