import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../error/exceptions.dart';

@lazySingleton
class KeyManagementService {
  final FlutterSecureStorage _secureStorage;
  static const _keyPrefix = 'video_key_';

  KeyManagementService(this._secureStorage);

  /// Gets the AES-256 key for a specific video, or generates a new one if it doesn't exist.
  Future<enc.Key> getKeyForVideo(String videoId) async {
    try {
      final keyBase64 = await _secureStorage.read(key: '$_keyPrefix$videoId');
      if (keyBase64 != null && keyBase64.isNotEmpty) {
        return enc.Key(base64.decode(keyBase64));
      }

      final random = Random.secure();
      final keyBytes = Uint8List.fromList(
        List<int>.generate(32, (_) => random.nextInt(256)),
      );
      final newKey = enc.Key(keyBytes);
      await _secureStorage.write(
        key: '$_keyPrefix$videoId',
        value: base64.encode(keyBytes),
      );
      return newKey;
    } catch (e) {
      throw EncryptionException(
        'Failed to manage encryption key for video $videoId: $e',
      );
    }
  }

  /// Removes the encryption key for a specific video.
  Future<void> removeKeyForVideo(String videoId) async {
    try {
      await _secureStorage.delete(key: '$_keyPrefix$videoId');
    } catch (e) {
      throw EncryptionException(
        'Failed to remove encryption key for video $videoId: $e',
      );
    }
  }
}
