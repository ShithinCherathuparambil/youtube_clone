import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_clone/domain/entities/download_item.dart';

void main() {
  const tItem = DownloadItem(
    videoId: 'vid123',
    title: 'Test Video',
    sourceUrl: 'https://youtube.com/watch?v=vid123',
    outputPath: '/tmp/vid123.encvid',
    status: DownloadStatus.completed,
    progress: 1.0,
    taskId: 'task_abc',
    videoHash: 'sha256hash',
    isEncrypted: true,
  );

  group('DownloadItem.copyWith', () {
    test('returns updated copy with new status', () {
      final updated = tItem.copyWith(status: DownloadStatus.failed);
      expect(updated.status, DownloadStatus.failed);
      expect(updated.videoId, tItem.videoId); // unchanged
    });

    test('returns updated copy with new progress', () {
      final updated = tItem.copyWith(progress: 0.5);
      expect(updated.progress, 0.5);
    });

    test('errorMessage is reset to null when not provided in copyWith', () {
      final itemWithError = tItem.copyWith(errorMessage: 'Something failed');
      // When copyWith is called without errorMessage, it should stay null
      final updated = itemWithError.copyWith(progress: 0.8);
      // errorMessage is always replaced by the provided value or null
      expect(updated.errorMessage, isNull);
    });

    test('isEncrypted defaults to false for new items', () {
      const fresh = DownloadItem(
        videoId: 'x',
        title: 'x',
        sourceUrl: 'x',
        outputPath: '',
        status: DownloadStatus.queued,
        progress: 0,
      );
      expect(fresh.isEncrypted, isFalse);
    });
  });

  group('DownloadItem.toMap / fromMap', () {
    test('round-trip (toMap then fromMap) produces equal object', () {
      final map = tItem.toMap();
      final restored = DownloadItem.fromMap(map);

      expect(restored.videoId, tItem.videoId);
      expect(restored.title, tItem.title);
      expect(restored.sourceUrl, tItem.sourceUrl);
      expect(restored.outputPath, tItem.outputPath);
      expect(restored.status, tItem.status);
      expect(restored.progress, tItem.progress);
      expect(restored.taskId, tItem.taskId);
      expect(restored.videoHash, tItem.videoHash);
      expect(restored.isEncrypted, tItem.isEncrypted);
    });

    test('toMap encodes status as integer index', () {
      final map = tItem.toMap();
      expect(map['status'], DownloadStatus.completed.index);
    });

    test('fromMap decodes all DownloadStatus enum values correctly', () {
      for (final status in DownloadStatus.values) {
        final map = tItem.toMap();
        map['status'] = status.index;
        final item = DownloadItem.fromMap(map);
        expect(item.status, status);
      }
    });

    test('fromMap handles missing isEncrypted (defaults to false)', () {
      final map = tItem.toMap();
      map.remove('isEncrypted');
      final item = DownloadItem.fromMap(map);
      expect(item.isEncrypted, isFalse);
    });
  });

  group('DownloadItem Equatable', () {
    test('two identical instances are equal', () {
      const item2 = DownloadItem(
        videoId: 'vid123',
        title: 'Test Video',
        sourceUrl: 'https://youtube.com/watch?v=vid123',
        outputPath: '/tmp/vid123.encvid',
        status: DownloadStatus.completed,
        progress: 1.0,
        taskId: 'task_abc',
        videoHash: 'sha256hash',
        isEncrypted: true,
      );
      expect(tItem, equals(item2));
    });

    test('items with different videoId are not equal', () {
      final other = tItem.copyWith(status: DownloadStatus.failed);
      expect(tItem, isNot(equals(other)));
    });
  });
}
