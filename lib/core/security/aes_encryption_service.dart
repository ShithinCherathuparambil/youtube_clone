import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../error/exceptions.dart';

/// Encrypts downloaded videos and keeps the AES key in secure storage.
///
/// Output format for encrypted bytes:
/// [16-byte IV][ciphertext bytes]
@lazySingleton
class AesEncryptionService {
  AesEncryptionService(this._secureStorage);

  static const _keyRef = 'youtube_clone_aes_256_key';
  final FlutterSecureStorage _secureStorage;

  Future<enc.Key> _getOrCreateKey() async {
    try {
      final saved = await _secureStorage.read(key: _keyRef);
      if (saved != null && saved.isNotEmpty) {
        return enc.Key(Uint8List.fromList(base64Decode(saved)));
      }

      final random = Random.secure();
      final keyBytes = Uint8List.fromList(
        List<int>.generate(32, (_) => random.nextInt(256)),
      );
      await _secureStorage.write(key: _keyRef, value: base64Encode(keyBytes));
      return enc.Key(keyBytes);
    } catch (e) {
      throw EncryptionException('Failed to access AES key: $e');
    }
  }

  Future<Uint8List> encryptBytes(Uint8List plainBytes) async {
    try {
      final key = await _getOrCreateKey();
      final iv = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);

      final output = BytesBuilder();
      output.add(iv.bytes);
      output.add(encrypted.bytes);
      return output.toBytes();
    } catch (e) {
      throw EncryptionException('Failed to encrypt bytes: $e');
    }
  }

  Future<Uint8List> decryptBytes(Uint8List encryptedPayload) async {
    try {
      if (encryptedPayload.length <= 16) {
        throw EncryptionException('Encrypted payload is invalid');
      }

      final key = await _getOrCreateKey();
      final iv = enc.IV(encryptedPayload.sublist(0, 16));
      final cipherBytes = encryptedPayload.sublist(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decryptBytes(
        enc.Encrypted(cipherBytes),
        iv: iv,
      );
      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw EncryptionException('Failed to decrypt bytes: $e');
    }
  }

  /// Decrypts an encrypted file and yields chunks for in-app playback.
  ///
  /// Note: this keeps the content private to app-controlled streams.
  Stream<List<int>> decryptFileAsStream(
    File encryptedFile, {
    int outputChunkSize = 64 * 1024,
  }) async* {
    try {
      final encryptedPayload = await encryptedFile.readAsBytes();
      final plainBytes = await decryptBytes(
        Uint8List.fromList(encryptedPayload),
      );

      for (var i = 0; i < plainBytes.length; i += outputChunkSize) {
        final end = (i + outputChunkSize < plainBytes.length)
            ? i + outputChunkSize
            : plainBytes.length;
        yield plainBytes.sublist(i, end);
      }
    } catch (e) {
      throw EncryptionException('Failed to stream decrypt file: $e');
    }
  }

  /// Decrypts to a temporary file for standard video player playback.
  /// The file is created in the temp directory and should be deleted after use.
  Future<File> decryptToTempFile(String videoId, String encryptedPath) async {
    try {
      final encryptedFile = File(encryptedPath);
      if (!await encryptedFile.exists()) {
        throw EncryptionException('Encrypted file not found');
      }

      final encryptedPayload = await encryptedFile.readAsBytes();
      final plainBytes = await decryptBytes(
        Uint8List.fromList(encryptedPayload),
      );

      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/decrypted_${videoId}_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      await tempFile.writeAsBytes(plainBytes, flush: true);
      return tempFile;
    } catch (e) {
      throw EncryptionException('Failed to decrypt to temp file: $e');
    }
  }
}
