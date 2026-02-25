import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/download_item.dart';

abstract class DownloadRepository {
  Future<Either<Failure, DownloadItem>> downloadAndEncrypt(
    DownloadItem item, {
    required void Function(double progress) onProgress,
  });

  Future<Either<Failure, List<DownloadItem>>> getCachedDownloads();
}
