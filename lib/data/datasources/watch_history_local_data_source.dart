import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/exceptions.dart';
import '../models/watch_history_model.dart';

abstract class WatchHistoryLocalDataSource {
  Future<void> addToHistory(WatchHistoryModel video);
  Future<List<WatchHistoryModel>> getWatchHistory();
  Future<void> clearHistory();
}

@LazySingleton(as: WatchHistoryLocalDataSource)
class WatchHistoryLocalDataSourceImpl implements WatchHistoryLocalDataSource {
  static const _boxName = 'watch_history_box';
  static const _maxItems = 100; // Keep the last 100 videos

  Future<Box> _openBox() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        return await Hive.openBox(_boxName);
      }
      return Hive.box(_boxName);
    } catch (e) {
      throw CacheException('Failed to open watch history box: $e');
    }
  }

  @override
  Future<void> addToHistory(WatchHistoryModel video) async {
    try {
      final box = await _openBox();

      // Remove if already exists (to move it to the top)
      await box.delete(video.id);

      // Add to box
      await box.put(video.id, video.toMap());

      // Trim if exceeds max items
      if (box.length > _maxItems) {
        final keys = box.keys.toList();
        // Since we want to keep the most recent, and Hive doesn't guarantee insertion order if we delete/re-add,
        // we should ideally sort by watchedAt if we want to be strict.
        // But for simplicity, let's just remove the first key if it's over limit.
        // A better way: convert to list, sort by date, keep top 100.
        final allItems = box.values
            .map(
              (e) => WatchHistoryModel.fromMap(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();

        allItems.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));

        if (allItems.length > _maxItems) {
          final toDelete = allItems.sublist(_maxItems);
          for (var item in toDelete) {
            await box.delete(item.id);
          }
        }
      }
    } catch (e) {
      throw CacheException('Failed to add to watch history: $e');
    }
  }

  @override
  Future<List<WatchHistoryModel>> getWatchHistory() async {
    try {
      final box = await _openBox();
      final items = box.values
          .map(
            (e) =>
                WatchHistoryModel.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      // Sort by recency
      items.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
      return items;
    } catch (e) {
      throw CacheException('Failed to get watch history: $e');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      final box = await _openBox();
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear watch history: $e');
    }
  }
}
