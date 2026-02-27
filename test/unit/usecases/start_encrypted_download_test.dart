import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube_clone/core/error/failures.dart';
import 'package:youtube_clone/domain/entities/download_item.dart';
import 'package:youtube_clone/domain/repositories/download_repository.dart';
import 'package:youtube_clone/domain/usecases/start_encrypted_download.dart';

class MockDownloadRepository extends Mock implements DownloadRepository {}

void main() {
  late MockDownloadRepository mockRepository;
  late StartEncryptedDownload useCase;

  const tItem = DownloadItem(
    videoId: 'vid1',
    title: 'My Video',
    sourceUrl: 'https://youtube.com/watch?v=vid1',
    outputPath: '',
    status: DownloadStatus.queued,
    progress: 0,
  );

  setUp(() {
    mockRepository = MockDownloadRepository();
    useCase = StartEncryptedDownload(mockRepository);
  });

  setUpAll(() {
    // Register fallback values for named args used in mocktail
    registerFallbackValue(tItem);
  });

  group('StartEncryptedDownload UseCase', () {
    test(
      'delegates to repository.downloadAndEncrypt with correct params',
      () async {
        final completed = tItem.copyWith(
          status: DownloadStatus.completed,
          progress: 1.0,
          isEncrypted: true,
        );

        when(
          () => mockRepository.downloadAndEncrypt(
            any(),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async => Right(completed));

        final params = StartEncryptedDownloadParams(
          item: tItem,
          onProgress: (_) {},
        );
        await useCase(params);

        verify(
          () => mockRepository.downloadAndEncrypt(
            tItem,
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
      },
    );

    test('returns Right(DownloadItem) on success', () async {
      final completed = tItem.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
        isEncrypted: true,
        videoHash: 'abc123hash',
      );

      when(
        () => mockRepository.downloadAndEncrypt(
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => Right(completed));

      final result = await useCase(
        StartEncryptedDownloadParams(item: tItem, onProgress: (_) {}),
      );

      expect(result.isRight(), isTrue);
      result.fold((l) => fail('Expected Right'), (r) {
        expect(r.status, DownloadStatus.completed);
        expect(r.isEncrypted, isTrue);
        expect(r.videoHash, 'abc123hash');
      });
    });

    test('returns Left(ServerFailure) when repository fails', () async {
      when(
        () => mockRepository.downloadAndEncrypt(
          any(),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to resolve stream')),
      );

      final result = await useCase(
        StartEncryptedDownloadParams(item: tItem, onProgress: (_) {}),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l.message, 'Failed to resolve stream'),
        (r) => fail('Expected Left'),
      );
    });
  });
}
