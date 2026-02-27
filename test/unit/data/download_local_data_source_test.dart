/// Unit tests for [DownloadLocalDataSourceImpl].
///
/// Uses an in-memory Hive box (via hive_test or a direct in-memory mock)
/// to verify caching, retrieval, and deletion without touching the real file system.

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:youtube_clone/data/datasources/download_local_data_source.dart';
import 'package:youtube_clone/domain/entities/download_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DownloadLocalDataSourceImpl dataSource;

  const tItem = DownloadItem(
    videoId: 'vid1',
    title: 'Test Video',
    sourceUrl: 'https://yt.com/vid1',
    outputPath: '/tmp/vid1.encvid',
    status: DownloadStatus.completed,
    progress: 1.0,
    isEncrypted: true,
    videoHash: 'hashABC',
  );

  const tItem2 = DownloadItem(
    videoId: 'vid2',
    title: 'Second Video',
    sourceUrl: 'https://yt.com/vid2',
    outputPath: '/tmp/vid2.encvid',
    status: DownloadStatus.downloading,
    progress: 0.5,
    isEncrypted: false,
  );

  setUp(() async {
    // Use an in-memory Hive box for tests
    Hive.init('/tmp/hive_test_${DateTime.now().microsecondsSinceEpoch}');
    dataSource = DownloadLocalDataSourceImpl();
  });

  tearDown(() async {
    final boxNames = Hive.isBoxOpen('downloads_box')
        ? ['downloads_box']
        : <String>[];
    for (final name in boxNames) {
      await Hive.box(name).clear();
      await Hive.box(name).close();
    }
    await Hive.deleteFromDisk();
  });

  group('DownloadLocalDataSource.cacheDownload', () {
    test('stores item so it can be retrieved by getDownloads', () async {
      await dataSource.cacheDownload(tItem);

      final results = await dataSource.getDownloads();

      expect(results.length, 1);
      expect(results.first.videoId, 'vid1');
      expect(results.first.title, 'Test Video');
    });

    test('overwrites existing item with same videoId', () async {
      await dataSource.cacheDownload(tItem);

      final updatedItem = tItem.copyWith(
        status: DownloadStatus.failed,
        progress: 0.0,
        errorMessage: 'Network error',
      );
      await dataSource.cacheDownload(updatedItem);

      final results = await dataSource.getDownloads();
      expect(results.length, 1);
      expect(results.first.status, DownloadStatus.failed);
      expect(results.first.errorMessage, 'Network error');
    });

    test('stores multiple items independently', () async {
      await dataSource.cacheDownload(tItem);
      await dataSource.cacheDownload(tItem2);

      final results = await dataSource.getDownloads();
      expect(results.length, 2);
    });

    test('preserves isEncrypted flag', () async {
      await dataSource.cacheDownload(tItem);
      final result = (await dataSource.getDownloads()).first;
      expect(result.isEncrypted, isTrue);
    });

    test('preserves videoHash', () async {
      await dataSource.cacheDownload(tItem);
      final result = (await dataSource.getDownloads()).first;
      expect(result.videoHash, 'hashABC');
    });
  });

  group('DownloadLocalDataSource.getDownloads', () {
    test('returns empty list when nothing is cached', () async {
      final results = await dataSource.getDownloads();
      expect(results, isEmpty);
    });

    test('returns all cached items', () async {
      await dataSource.cacheDownload(tItem);
      await dataSource.cacheDownload(tItem2);

      final results = await dataSource.getDownloads();
      final ids = results.map((e) => e.videoId).toSet();
      expect(ids, containsAll(['vid1', 'vid2']));
    });

    test('correctly deserializes DownloadStatus.downloading', () async {
      await dataSource.cacheDownload(tItem2);

      final result = (await dataSource.getDownloads()).first;
      expect(result.status, DownloadStatus.downloading);
      expect(result.progress, closeTo(0.5, 0.001));
    });
  });

  group('DownloadLocalDataSource.deleteDownload', () {
    test('removes item with matching videoId', () async {
      await dataSource.cacheDownload(tItem);
      await dataSource.cacheDownload(tItem2);

      await dataSource.deleteDownload('vid1');

      final results = await dataSource.getDownloads();
      expect(results.length, 1);
      expect(results.first.videoId, 'vid2');
    });

    test('is a no-op when the videoId does not exist', () async {
      await dataSource.cacheDownload(tItem);
      // Should not throw
      await dataSource.deleteDownload('nonexistent');

      final results = await dataSource.getDownloads();
      expect(results.length, 1);
    });

    test('leaves box empty after deleting the only item', () async {
      await dataSource.cacheDownload(tItem);
      await dataSource.deleteDownload('vid1');

      final results = await dataSource.getDownloads();
      expect(results, isEmpty);
    });
  });
}
