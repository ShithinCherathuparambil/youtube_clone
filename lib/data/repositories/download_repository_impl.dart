import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/security/aes_encryption_service.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/download_local_data_source.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../services/background_download_service.dart';

@LazySingleton(as: DownloadRepository)
class DownloadRepositoryImpl implements DownloadRepository {
  DownloadRepositoryImpl(
    this._backgroundDownloadService,
    this._localDataSource,
    this._encryptionService,
    this._notifications,
  );

  final BackgroundDownloadService _backgroundDownloadService;
  final DownloadLocalDataSource _localDataSource;
  final AesEncryptionService _encryptionService;
  final FlutterLocalNotificationsPlugin _notifications;

  @override
  Future<Either<Failure, DownloadItem>> downloadAndEncrypt(
    DownloadItem item, {
    required void Function(double progress) onProgress,
  }) async {
    try {
      String playableUrl = item.sourceUrl;

      // Resolve YouTube URL to direct stream URL
      if (playableUrl.contains('youtube.com') ||
          playableUrl.contains('youtu.be')) {
        final yt = YoutubeExplode();
        try {
          final videoId = VideoId.parseVideoId(playableUrl);
          if (videoId == null) {
            return Left(ServerFailure('Invalid YouTube URL'));
          }

          final manifest = await yt.videos.streamsClient.getManifest(videoId);

          StreamInfo? streamInfo;
          try {
            streamInfo = manifest.muxed.withHighestBitrate();
          } catch (_) {
            // No muxed streams
            if (manifest.streams.isNotEmpty) {
              streamInfo = manifest.streams.first;
            }
          }

          if (streamInfo != null) {
            playableUrl = streamInfo.url.toString();
            debugPrint(
              'DownloadRepository: Resolved to stream: ${streamInfo.size}',
            );
          } else {
            return Left(
              ServerFailure('No playable stream found for this video'),
            );
          }
        } catch (e) {
          debugPrint('DownloadRepository: Failed to resolve YouTube URL: $e');
          return Left(ServerFailure('Failed to resolve video stream: $e'));
        } finally {
          yt.close();
        }
      }

      // 1. Enqueue background download
      final taskId = await _backgroundDownloadService.enqueue(
        url: playableUrl,
        fileName: '${item.videoId}.mp4',
      );

      if (taskId == null) {
        return Left(ServerFailure('Failed to enqueue download'));
      }

      var currentItem = item.copyWith(
        taskId: taskId,
        status: DownloadStatus.downloading,
      );
      await _localDataSource.cacheDownload(currentItem);

      // 2. Listen to progress and wait for completion
      final completer = Completer<Either<Failure, DownloadItem>>();

      late StreamSubscription subscription;
      subscription = _backgroundDownloadService.progressStream.listen((
        update,
      ) async {
        if (update.taskId == taskId) {
          onProgress(update.progress);

          if (update.status == DownloadTaskStatus.complete) {
            subscription.cancel();

            // 3. Perform encryption
            try {
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/${item.videoId}.mp4');

              if (!await tempFile.exists()) {
                completer.complete(
                  Left(ServerFailure('Downloaded file not found')),
                );
                return;
              }

              final fileSize = await tempFile.length();
              if (fileSize < 1024 * 1024) {
                // Less than 1MB
                completer.complete(
                  Left(
                    ServerFailure(
                      'Downloaded file is too small ($fileSize bytes). This is likely an error page or corrupted stream.',
                    ),
                  ),
                );
                await tempFile.delete();
                return;
              }

              final bytes = await tempFile.readAsBytes();
              final encryptedBytes = await _encryptionService.encryptBytes(
                bytes,
              );

              final outputDirectory = await _ensureOutputDirectory();
              final outputFile = File(
                '${outputDirectory.path}/${item.videoId}.encvid',
              );
              await outputFile.writeAsBytes(encryptedBytes, flush: true);

              await tempFile.delete();

              final completed = currentItem.copyWith(
                status: DownloadStatus.completed,
                progress: 1.0,
                outputPath: outputFile.path,
              );
              await _localDataSource.cacheDownload(completed);

              // 4. Trigger local notification
              await _notifications.show(
                item.videoId.hashCode,
                'Download Complete',
                '${item.title} has been downloaded and encrypted.',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'downloads_channel',
                    'Downloads',
                    importance: Importance.max,
                    priority: Priority.high,
                  ),
                ),
              );

              completer.complete(Right(completed));
            } catch (e) {
              completer.complete(Left(ServerFailure('Encryption failed: $e')));
            }
          } else if (update.status == DownloadTaskStatus.failed) {
            subscription.cancel();
            completer.complete(
              Left(ServerFailure('Download failed in background')),
            );
          }
        }
      });

      return completer.future;
    } catch (e) {
      return Left(ServerFailure('Unknown download error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDownload(String videoId) async {
    try {
      final downloads = await _localDataSource.getDownloads();
      final item = downloads.firstWhere((e) => e.videoId == videoId);

      // 1. Delete from Hive
      await _localDataSource.deleteDownload(videoId);

      // 2. Delete encrypted file
      if (item.outputPath.isNotEmpty) {
        final file = File(item.outputPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // 3. Remove from flutter_downloader if it's still there
      if (item.taskId != null) {
        await _backgroundDownloadService.remove(item.taskId!);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete download: $e'));
    }
  }

  @override
  Future<Either<Failure, File>> getDecryptedFile(
    String videoId,
    String encryptedPath,
  ) async {
    try {
      final decryptedFile = await _encryptionService.decryptToTempFile(
        videoId,
        encryptedPath,
      );
      return Right(decryptedFile);
    } catch (e) {
      return Left(ServerFailure('Decryption failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DownloadItem>>> getCachedDownloads() async {
    try {
      final downloads = await _localDataSource.getDownloads();
      return Right(downloads);
    } catch (e) {
      return Left(CacheFailure('Failed to get cached downloads: $e'));
    }
  }

  Future<Directory> _ensureOutputDirectory() async {
    final directory = Directory(
      '${Directory.systemTemp.path}/encrypted_videos',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }
}
