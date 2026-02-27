import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube_clone/core/error/failures.dart';
import 'package:youtube_clone/core/services/storage_service.dart';
import 'package:youtube_clone/core/usecases/usecase.dart';
import 'package:youtube_clone/domain/entities/download_item.dart';
import 'package:youtube_clone/domain/entities/storage_info.dart';
import 'package:youtube_clone/domain/usecases/delete_download.dart';
import 'package:youtube_clone/domain/usecases/get_cached_downloads.dart';
import 'package:youtube_clone/domain/usecases/get_decrypted_file.dart';
import 'package:youtube_clone/domain/usecases/start_encrypted_download.dart';
import 'package:youtube_clone/presentation/bloc/download/download_manager_cubit.dart';
import 'package:youtube_clone/presentation/bloc/download/download_manager_state.dart';

class MockStartEncryptedDownload extends Mock
    implements StartEncryptedDownload {}

class MockGetCachedDownloads extends Mock implements GetCachedDownloads {}

class MockDeleteDownload extends Mock implements DeleteDownload {}

class MockGetDecryptedFile extends Mock implements GetDecryptedFile {}

class MockStorageService extends Mock implements StorageService {}

const tItem1 = DownloadItem(
  videoId: 'vid1',
  title: 'Video 1',
  sourceUrl: 'https://yt.com/1',
  outputPath: '/tmp/vid1.encvid',
  status: DownloadStatus.completed,
  progress: 1.0,
  isEncrypted: true,
  videoHash: 'hash1',
);

const tItem2 = DownloadItem(
  videoId: 'vid2',
  title: 'Video 2',
  sourceUrl: 'https://yt.com/2',
  outputPath: '/tmp/vid2.encvid',
  status: DownloadStatus.completed,
  progress: 1.0,
  isEncrypted: true,
  videoHash: 'hash2',
);

const tStorageInfo = StorageInfo(
  totalSpaceGB: 128.0,
  freeSpaceGB: 64.0,
  appUsedSpaceGB: 2.5,
);

void main() {
  late MockStartEncryptedDownload mockStart;
  late MockGetCachedDownloads mockGetCached;
  late MockDeleteDownload mockDelete;
  late MockGetDecryptedFile mockGetDecrypted;
  late MockStorageService mockStorageService;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const DeleteDownloadParams(videoIds: []));
    registerFallbackValue(
      GetDecryptedFileParams(videoId: '', encryptedPath: ''),
    );
    registerFallbackValue(
      StartEncryptedDownloadParams(item: tItem1, onProgress: (_) {}),
    );
  });

  setUp(() {
    mockStart = MockStartEncryptedDownload();
    mockGetCached = MockGetCachedDownloads();
    mockDelete = MockDeleteDownload();
    mockGetDecrypted = MockGetDecryptedFile();
    mockStorageService = MockStorageService();
  });

  DownloadManagerCubit buildCubit() => DownloadManagerCubit(
    mockStart,
    mockGetCached,
    mockDelete,
    mockGetDecrypted,
    mockStorageService,
  );

  group('DownloadManagerCubit - loadCachedDownloads', () {
    blocTest<DownloadManagerCubit, DownloadManagerState>(
      'emits [loading=true, isLoading=false + downloads] on success',
      build: buildCubit,
      setUp: () {
        when(
          () => mockGetCached(any()),
        ).thenAnswer((_) async => const Right([tItem1, tItem2]));
      },
      act: (c) => c.loadCachedDownloads(),
      expect: () => [
        const DownloadManagerState(isLoading: true, error: null),
        const DownloadManagerState(
          isLoading: false,
          downloads: [tItem1, tItem2],
          error: null,
        ),
      ],
    );

    blocTest<DownloadManagerCubit, DownloadManagerState>(
      'emits [loading=true, isLoading=false + error] on failure',
      build: buildCubit,
      setUp: () {
        when(
          () => mockGetCached(any()),
        ).thenAnswer((_) async => const Left(CacheFailure('DB error')));
      },
      act: (c) => c.loadCachedDownloads(),
      expect: () => [
        const DownloadManagerState(isLoading: true),
        const DownloadManagerState(isLoading: false, error: 'DB error'),
      ],
    );
  });

  group('DownloadManagerCubit - deleteDownloads', () {
    blocTest<DownloadManagerCubit, DownloadManagerState>(
      'removes items from state list and reloads storage on success',
      build: buildCubit,
      seed: () => const DownloadManagerState(downloads: [tItem1, tItem2]),
      setUp: () {
        when(
          () => mockDelete(any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockStorageService.getStorageInfo(),
        ).thenAnswer((_) async => tStorageInfo);
      },
      act: (c) => c.deleteDownloads(['vid1']),
      expect: () => [
        // After delete: vid1 removed
        const DownloadManagerState(downloads: [tItem2]),
        // After storage refresh
        const DownloadManagerState(
          downloads: [tItem2],
          storageInfo: tStorageInfo,
        ),
      ],
    );

    blocTest<DownloadManagerCubit, DownloadManagerState>(
      'emits error state when delete fails',
      build: buildCubit,
      seed: () => const DownloadManagerState(downloads: [tItem1]),
      setUp: () {
        when(
          () => mockDelete(any()),
        ).thenAnswer((_) async => const Left(CacheFailure('Delete failed')));
      },
      act: (c) => c.deleteDownloads(['vid1']),
      expect: () => [
        const DownloadManagerState(downloads: [tItem1], error: 'Delete failed'),
      ],
    );
  });

  group('DownloadManagerCubit - getDecryptedFile', () {
    test('returns File on success', () async {
      final file = File('/tmp/decrypted.mp4');
      when(() => mockGetDecrypted(any())).thenAnswer((_) async => Right(file));

      final cubit = buildCubit();
      final result = await cubit.getDecryptedFile('vid1', '/tmp/vid1.encvid');

      expect(result, isA<File>());
    });

    test('returns null and emits error on failure', () async {
      when(() => mockGetDecrypted(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Integrity check failed')),
      );

      final cubit = buildCubit();
      final result = await cubit.getDecryptedFile('vid1', '/tmp/vid1.encvid');

      expect(result, isNull);
      expect(cubit.state.error, 'Integrity check failed');
    });
  });

  group('DownloadManagerCubit - initial state', () {
    test('initial state has empty downloads and isLoading=false', () {
      final cubit = buildCubit();
      expect(cubit.state.downloads, isEmpty);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.error, isNull);
    });
  });
}
