import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/exceptions.dart';
import '../../domain/entities/download_item.dart';

abstract class DownloadLocalDataSource {
  Future<void> cacheDownload(DownloadItem item);
  Future<List<DownloadItem>> getDownloads();
}

@LazySingleton(as: DownloadLocalDataSource)
class DownloadLocalDataSourceImpl implements DownloadLocalDataSource {
  DownloadLocalDataSourceImpl();

  static const _boxName = 'encrypted_downloads_box';

  Future<Box<Map>> _openBox() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return await Hive.openBox<Map>(_boxName);
      }
      return Hive.box<Map>(_boxName);
    } catch (e) {
      throw CacheException('Failed to open Hive box: $e');
    }
  }

  @override
  Future<void> cacheDownload(DownloadItem item) async {
    try {
      final box = await _openBox();
      await box.put(item.videoId, {
        'videoId': item.videoId,
        'title': item.title,
        'sourceUrl': item.sourceUrl,
        'outputPath': item.outputPath,
        'status': item.status.name,
        'progress': item.progress,
        'errorMessage': item.errorMessage,
      });
    } catch (e) {
      throw CacheException('Failed to cache download: $e');
    }
  }

  @override
  Future<List<DownloadItem>> getDownloads() async {
    try {
      final box = await _openBox();
      return box.values
          .map(
            (raw) => DownloadItem(
              videoId: raw['videoId'] as String,
              title: raw['title'] as String,
              sourceUrl: raw['sourceUrl'] as String,
              outputPath: raw['outputPath'] as String,
              status: DownloadStatus.values.byName(raw['status'] as String),
              progress: (raw['progress'] as num).toDouble(),
              errorMessage: raw['errorMessage'] as String?,
            ),
          )
          .toList(growable: false);
    } catch (e) {
      throw CacheException('Failed to get cached downloads: $e');
    }
  }
}
