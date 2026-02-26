import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storage_space/storage_space.dart';
import '../../domain/entities/storage_info.dart';

@lazySingleton
class StorageService {
  Future<StorageInfo> getStorageInfo() async {
    final storageSpace = await getStorageSpace(
      lowOnSpaceThreshold: 1024 * 1024 * 1024, // 1GB
      fractionDigits: 2,
    );

    final appDirectory = await getApplicationDocumentsDirectory();
    final appUsedSpaceBytes = await _getDirectorySize(appDirectory);

    // storage_space returns sizes as strings for some reason in some versions,
    // or the lints suggest they are strings. Let's use the provided doubles if available
    // or parse them.
    return StorageInfo(
      totalSpaceGB: storageSpace.totalSizeInBytes / (1024 * 1024 * 1024),
      freeSpaceGB: storageSpace.freeSizeInBytes / (1024 * 1024 * 1024),
      appUsedSpaceGB: appUsedSpaceBytes / (1024 * 1024 * 1024),
    );
  }

  Future<int> _getDirectorySize(Directory directory) async {
    int totalSize = 0;
    try {
      if (await directory.exists()) {
        await for (var entity in directory.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      // ignore
    }
    return totalSize;
  }
}
