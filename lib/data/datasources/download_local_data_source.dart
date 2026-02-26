import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/exceptions.dart';
import '../../domain/entities/download_item.dart';

abstract class DownloadLocalDataSource {
  Future<void> cacheDownload(DownloadItem item);
  Future<List<DownloadItem>> getDownloads();
  Future<void> deleteDownload(String videoId);
}

@LazySingleton(as: DownloadLocalDataSource)
class DownloadLocalDataSourceImpl implements DownloadLocalDataSource {
  static const _boxName = 'downloads_box';

  Future<Box> _openBox() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return await Hive.openBox(_boxName);
      }
      return Hive.box(_boxName);
    } catch (e) {
      throw CacheException('Failed to open Hive box: $e');
    }
  }

  @override
  Future<void> cacheDownload(DownloadItem item) async {
    try {
      final box = await _openBox();
      await box.put(item.videoId, item.toMap());
    } catch (e) {
      throw CacheException('Failed to cache download: $e');
    }
  }

  @override
  Future<List<DownloadItem>> getDownloads() async {
    try {
      final box = await _openBox();
      return box.values
          .map((e) => DownloadItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached downloads: $e');
    }
  }

  @override
  Future<void> deleteDownload(String videoId) async {
    try {
      final box = await _openBox();
      await box.delete(videoId);
    } catch (e) {
      throw CacheException('Failed to delete download: $e');
    }
  }
}
