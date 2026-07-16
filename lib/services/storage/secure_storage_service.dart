import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:globaledu_ai/core/utils/logger.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  // Keys
  static const String _fcmTokenKey = 'fcm_token';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _lastSyncKey = 'last_sync';

  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      AppLogger.error('Secure storage write failed', e);
    }
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      AppLogger.error('Secure storage read failed', e);
      return null;
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      AppLogger.error('Secure storage delete failed', e);
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      AppLogger.error('Secure storage deleteAll failed', e);
    }
  }

  // Convenience methods
  Future<void> saveFcmToken(String token) => write(_fcmTokenKey, token);
  Future<String?> getFcmToken() => read(_fcmTokenKey);

  Future<void> setOnboardingComplete() =>
      write(_onboardingCompleteKey, 'true');
  Future<bool> isOnboardingComplete() async {
    final value = await read(_onboardingCompleteKey);
    return value == 'true';
  }

  Future<void> setLastSync(DateTime dateTime) =>
      write(_lastSyncKey, dateTime.toIso8601String());
  Future<DateTime?> getLastSync() async {
    final value = await read(_lastSyncKey);
    return value != null ? DateTime.tryParse(value) : null;
  }
}
