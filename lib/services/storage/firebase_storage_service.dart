import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:globaledu_ai/core/config/firebase_guard.dart';
import 'package:globaledu_ai/core/errors/exceptions.dart';
import 'package:globaledu_ai/core/utils/logger.dart';

class FirebaseStorageService {
  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = FirebaseGuard.isInitialized
            ? (storage ?? FirebaseStorage.instance)
            : null;

  final FirebaseStorage? _storage;

  /// Upload bytes and return download URL (works on all platforms).
  Future<String> uploadBytes({
    required Uint8List data,
    required String path,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    if (_storage == null) {
      throw StorageException(message: 'Firebase not configured');
    }
    try {
      final ref = _storage!.ref(path);
      final uploadTask = ref.putData(
        data,
        SettableMetadata(
          contentType: contentType ?? 'application/octet-stream',
          customMetadata: metadata,
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      AppLogger.info('File uploaded: $path');
      return downloadUrl;
    } catch (e) {
      AppLogger.error('Upload failed', e);
      throw StorageException(message: 'Failed to upload file');
    }
  }

  /// Upload user profile photo.
  Future<String> uploadProfilePhoto({
    required String userId,
    required Uint8List data,
    String contentType = 'image/jpeg',
  }) async {
    return uploadBytes(
      data: data,
      path: 'users/$userId/profile/photo_${DateTime.now().millisecondsSinceEpoch}',
      contentType: contentType,
    );
  }

  /// Upload application document.
  Future<String> uploadDocument({
    required String userId,
    required String applicationId,
    required Uint8List data,
    required String documentName,
    String? contentType,
  }) async {
    return uploadBytes(
      data: data,
      path: 'users/$userId/applications/$applicationId/documents/$documentName',
      contentType: contentType ?? _getContentType(documentName),
      metadata: {'originalName': documentName},
    );
  }

  /// Delete a file by URL.
  Future<void> deleteFile(String downloadUrl) async {
    if (_storage == null) return;
    try {
      final ref = _storage!.refFromURL(downloadUrl);
      await ref.delete();
      AppLogger.info('File deleted: ${ref.fullPath}');
    } catch (e) {
      AppLogger.error('Delete failed', e);
    }
  }

  /// Get download URL from path.
  Future<String?> getDownloadUrl(String path) async {
    if (_storage == null) return null;
    try {
      return await _storage!.ref(path).getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  String _getContentType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}
