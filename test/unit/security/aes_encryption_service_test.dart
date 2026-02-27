import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:youtube_clone/core/security/aes_encryption_service.dart';
import 'package:youtube_clone/core/security/key_management_service.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempPath;
  MockPathProviderPlatform(this.tempPath);

  @override
  Future<String?> getTemporaryPath() async => tempPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempPath;

  @override
  Future<String?> getApplicationSupportPath() async => tempPath;

  @override
  Future<String?> getLibraryPath() async => null;

  @override
  Future<String?> getExternalStoragePath() async => null;

  @override
  Future<List<String>?> getExternalCachePaths() async => null;

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => null;

  @override
  Future<String?> getDownloadsPath() async => null;
}

class MockKeyManagementService extends Mock implements KeyManagementService {}

void main() {
  late MockKeyManagementService mockKeyMgmt;
  late AesEncryptionService service;
  late enc.Key testKey;
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('aes_test_');
    // Register a fake path_provider so getTemporaryDirectory() resolves in tests
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);
    // Generate a deterministic 256-bit key for testing
    final keyBytes = Uint8List.fromList(List.generate(32, (i) => i + 1));
    testKey = enc.Key(keyBytes);
  });

  setUp(() {
    mockKeyMgmt = MockKeyManagementService();
    service = AesEncryptionService(mockKeyMgmt);

    when(
      () => mockKeyMgmt.getKeyForVideo(any()),
    ).thenAnswer((_) async => testKey);
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  File _tempFile(String name, List<int> bytes) {
    final f = File('${tempDir.path}/$name');
    f.writeAsBytesSync(bytes);
    return f;
  }

  group('AesEncryptionService.encryptFile', () {
    test('encrypted file is larger than input (IV prefix appended)', () async {
      final content = List<int>.generate(1024 * 10, (i) => i % 256);
      final input = _tempFile('plain.mp4', content);
      final output = File('${tempDir.path}/enc.encvid');

      await service.encryptFile(
        inputFile: input,
        outputFile: output,
        videoId: 'vid_test',
      );

      // AES-CTR output is same size as input + 16-byte IV prepended
      expect(await output.length(), content.length + 16);
    });

    test('returns a non-empty SHA-256 hash string', () async {
      final content = List<int>.generate(512, (i) => i % 256);
      final input = _tempFile('plain2.mp4', content);
      final output = File('${tempDir.path}/enc2.encvid');

      final hash = await service.encryptFile(
        inputFile: input,
        outputFile: output,
        videoId: 'vid_test2',
      );

      expect(hash, isNotEmpty);
      // SHA-256 hex string: 64 chars
      expect(hash.length, 64);
    });

    test(
      'two encryptions of same content produce different ciphertext (unique IVs)',
      () async {
        final content = List<int>.generate(1024, (i) => 0xAB);
        final input = _tempFile('plain3.mp4', content);
        final out1 = File('${tempDir.path}/enc3a.encvid');
        final out2 = File('${tempDir.path}/enc3b.encvid');

        await service.encryptFile(
          inputFile: input,
          outputFile: out1,
          videoId: 'vid_iv1',
        );
        await service.encryptFile(
          inputFile: input,
          outputFile: out2,
          videoId: 'vid_iv2',
        );

        // Ciphertexts (including IVs) should differ
        expect(
          await out1.readAsBytes(),
          isNot(equals(await out2.readAsBytes())),
        );
      },
    );
  });

  group('AesEncryptionService.decryptToTempFile', () {
    test('encrypt → decrypt round-trip restores original content', () async {
      final originalContent = List<int>.generate(1024 * 5, (i) => i % 256);
      final input = _tempFile('video_orig.mp4', originalContent);
      final encrypted = File('${tempDir.path}/video_enc.encvid');

      // Encrypt
      final hash = await service.encryptFile(
        inputFile: input,
        outputFile: encrypted,
        videoId: 'roundtrip_vid',
      );

      // Decrypt
      final decryptedFile = await service.decryptToTempFile(
        videoId: 'roundtrip_vid',
        encryptedPath: encrypted.path,
        expectedHash: hash,
      );

      final decryptedBytes = await decryptedFile.readAsBytes();
      expect(decryptedBytes, equals(originalContent));

      // Cleanup temp decrypted file
      await decryptedFile.delete();
    });

    test(
      'throws EncryptionException on integrity check failure (tampered file)',
      () async {
        final content = List<int>.generate(2048, (i) => i % 256);
        final input = _tempFile('tampered.mp4', content);
        final encrypted = File('${tempDir.path}/tampered_enc.encvid');

        // Encrypt
        final hash = await service.encryptFile(
          inputFile: input,
          outputFile: encrypted,
          videoId: 'tamper_vid',
        );

        // Tamper with the encrypted file (flip a byte in ciphertext)
        final bytes = await encrypted.readAsBytes();
        bytes[20] ^= 0xFF; // Flip byte after the 16-byte IV
        await encrypted.writeAsBytes(bytes);

        // Decrypt should throw due to hash mismatch
        expect(
          () => service.decryptToTempFile(
            videoId: 'tamper_vid',
            encryptedPath: encrypted.path,
            expectedHash: hash,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('throws EncryptionException when encrypted file is missing', () async {
      expect(
        () => service.decryptToTempFile(
          videoId: 'missing_vid',
          encryptedPath: '/nonexistent/path/video.encvid',
          expectedHash: 'anyhash',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
