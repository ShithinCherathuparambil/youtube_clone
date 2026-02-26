import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/download_item.dart';

abstract class DownloadRepository {
  Future<Either<Failure, DownloadItem>> downloadAndEncrypt(
    DownloadItem item, {
    required void Function(double progress) onProgress,
  });

  Future<Either<Failure, List<DownloadItem>>> getCachedDownloads();

  Future<Either<Failure, void>> deleteDownload(String videoId);

  Future<Either<Failure, File>> getDecryptedFile(
    String videoId,
    String encryptedPath,
  );
}
