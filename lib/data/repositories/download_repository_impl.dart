import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/security/aes_encryption_service.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/download_local_data_source.dart';
import '../services/background_download_service.dart';

@LazySingleton(as: DownloadRepository)
class DownloadRepositoryImpl implements DownloadRepository {
  DownloadRepositoryImpl(
    this._backgroundDownloadService,
    this._localDataSource,
    this._encryptionService,
  );

  final BackgroundDownloadService _backgroundDownloadService;
  final DownloadLocalDataSource _localDataSource;
  final AesEncryptionService _encryptionService;

  @override
  Future<Either<Failure, DownloadItem>> downloadAndEncrypt(
    DownloadItem item, {
    required void Function(double progress) onProgress,
  }) async {
    try {
      final tempFile = await _backgroundDownloadService.startDownload(
        sourceUrl: item.sourceUrl,
        fileName: '${item.videoId}.mp4',
        onProgress: onProgress,
      );

      final bytes = await tempFile.readAsBytes();
      final encryptedBytes = await _encryptionService.encryptBytes(bytes);

      final outputDirectory = await _ensureOutputDirectory();
      final outputFile = File('${outputDirectory.path}/${item.videoId}.encvid');
      await outputFile.writeAsBytes(encryptedBytes, flush: true);

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final completed = item.copyWith(
        status: DownloadStatus.completed,
        progress: 1,
        outputPath: outputFile.path,
      );
      await _localDataSource.cacheDownload(completed);
      return Right(completed);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on EncryptionException catch (e) {
      return Left(EncryptionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown download error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DownloadItem>>> getCachedDownloads() async {
    try {
      final downloads = await _localDataSource.getDownloads();
      return Right(downloads);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unknown cache error: $e'));
    }
  }

  Future<Directory> _ensureOutputDirectory() async {
    final directory = Directory('${Directory.systemTemp.path}/encrypted_videos');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }
}
