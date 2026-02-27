import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/export.dart' as pc;

import '../error/exceptions.dart';
import 'key_management_service.dart';

/// Service for handling secure video encryption and decryption.
/// Uses AES-256 (CTR) for encryption and SHA-256 for integrity checking.
@lazySingleton
class AesEncryptionService {
  final KeyManagementService _keyManagementService;

  AesEncryptionService(this._keyManagementService);

  static const int _chunkSize = 1024 * 1024; // 1MB buffer

  /// Encrypts a file using AES-256 CTR mode.
  /// Returns the SHA-256 hash of the original content.
  Future<String> encryptFile({
    required File inputFile,
    required File outputFile,
    required String videoId,
    Function(double progress)? onProgress,
  }) async {
    RandomAccessFile? inRaf;
    RandomAccessFile? outRaf;
    try {
      final key = await _keyManagementService.getKeyForVideo(videoId);
      final iv = enc.IV.fromSecureRandom(16);

      // Initialize PointyCastle CTR cipher
      final cipher = pc.CTRStreamCipher(pc.AESEngine())
        ..init(true, pc.ParametersWithIV(pc.KeyParameter(key.bytes), iv.bytes));

      inRaf = await inputFile.open(mode: FileMode.read);
      outRaf = await outputFile.open(mode: FileMode.write);

      // 1. Write IV (16 bytes)
      await outRaf.writeFrom(iv.bytes);

      final totalSize = await inRaf.length();
      int processedSize = 0;

      final hashAccumulator = AccumulatorSink<Digest>();
      final shaSink = sha256.startChunkedConversion(hashAccumulator);

      final buffer = Uint8List(_chunkSize);
      while (processedSize < totalSize) {
        final bytesRead = await inRaf.readInto(buffer);
        if (bytesRead == 0) break;

        final chunk = buffer.sublist(0, bytesRead);

        // Update hash with original bytes
        shaSink.add(chunk);

        // Encrypt chunk
        final encryptedChunk = cipher.process(chunk);
        await outRaf.writeFrom(encryptedChunk);

        processedSize += bytesRead;
        if (onProgress != null) {
          onProgress(processedSize / totalSize);
        }
      }

      shaSink.close();
      return hashAccumulator.events.single.toString();
    } catch (e) {
      throw EncryptionException('Encryption failed: $e');
    } finally {
      await inRaf?.close();
      await outRaf?.close();
    }
  }

  /// Decrypts a file using AES-256 CTR mode.
  /// Verifies integrity against the provided expectedHash.
  Future<File> decryptToTempFile({
    required String videoId,
    required String encryptedPath,
    required String expectedHash,
    Function(double progress)? onProgress,
  }) async {
    RandomAccessFile? inRaf;
    RandomAccessFile? outRaf;
    File? tempFile;
    try {
      final encryptedFile = File(encryptedPath);
      if (!await encryptedFile.exists()) {
        throw EncryptionException('Encrypted file not found: $encryptedPath');
      }

      final key = await _keyManagementService.getKeyForVideo(videoId);
      inRaf = await encryptedFile.open(mode: FileMode.read);

      // 1. Read IV (16 bytes)
      final ivBytes = await inRaf.read(16);
      if (ivBytes.length < 16) {
        throw EncryptionException('Invalid encrypted file: IV missing');
      }
      final iv = enc.IV(ivBytes);

      // Initialize PointyCastle CTR cipher for decryption
      final cipher = pc.CTRStreamCipher(
        pc.AESEngine(),
      )..init(false, pc.ParametersWithIV(pc.KeyParameter(key.bytes), iv.bytes));

      final tempDir = await getTemporaryDirectory();
      tempFile = File(
        '${tempDir.path}/decrypted_${videoId}_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      outRaf = await tempFile.open(mode: FileMode.write);

      final totalSize = await inRaf.length() - 16;
      int processedSize = 0;

      final hashAccumulator = AccumulatorSink<Digest>();
      final shaSink = sha256.startChunkedConversion(hashAccumulator);

      final buffer = Uint8List(_chunkSize);
      while (processedSize < totalSize) {
        final bytesRead = await inRaf.readInto(buffer);
        if (bytesRead == 0) break;

        final chunk = buffer.sublist(0, bytesRead);

        // Decrypt chunk
        final decryptedChunk = cipher.process(chunk);
        await outRaf.writeFrom(decryptedChunk);

        // Update hash with decrypted bytes
        shaSink.add(decryptedChunk);

        processedSize += bytesRead;
        if (onProgress != null) {
          onProgress(processedSize / totalSize);
        }
      }

      shaSink.close();
      final actualHash = hashAccumulator.events.single.toString();

      if (actualHash != expectedHash) {
        throw EncryptionException(
          'Integrity check failed: File is corrupt or tempered with.',
        );
      }

      return tempFile;
    } catch (e) {
      // Clean up temp file on failure
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
      throw EncryptionException('Decryption failed: $e');
    } finally {
      await inRaf?.close();
      await outRaf?.close();
    }
  }

  /// Optional: Clean up decryption keys when video is deleted.
  Future<void> removeVideoKey(String videoId) async {
    await _keyManagementService.removeKeyForVideo(videoId);
  }
}
