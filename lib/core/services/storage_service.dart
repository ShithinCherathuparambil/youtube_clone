import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storage_space/storage_space.dart';
import '../../domain/entities/storage_info.dart';

@lazySingleton
class StorageService {
  Future<StorageInfo> getStorageInfo() async {
    double totalGB = 0;
    double freeGB = 0;

    try {
      final storageSpace = await getStorageSpace(
        lowOnSpaceThreshold: 1024 * 1024 * 1024, // 1GB
        fractionDigits: 2,
      );

      // storage_space 1.2.0 uses 'totalSize' and 'freeSize' as strings.
      // If totalSize is "100.00 GB", we parse the number.
      totalGB = double.tryParse(storageSpace.totalSize.split(' ')[0]) ?? 0;
      freeGB = double.tryParse(storageSpace.freeSize.split(' ')[0]) ?? 0;
    } catch (e) {
      // Fallback if plugin fails
      totalGB = 128.0; // Mocked default
      freeGB = 50.0;
    }

    final appDirectory = await getApplicationDocumentsDirectory();
    final appUsedSpaceBytes = await _getDirectorySize(appDirectory);

    return StorageInfo(
      totalSpaceGB: totalGB,
      freeSpaceGB: freeGB,
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
