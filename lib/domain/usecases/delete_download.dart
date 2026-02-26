import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/download_repository.dart';
import '../../data/datasources/download_local_data_source.dart';

class DeleteDownload implements UseCase<void, DeleteDownloadParams> {
  DeleteDownload(this.repository, this.localDataSource);

  final DownloadRepository repository;
  final DownloadLocalDataSource localDataSource;

  @override
  Future<Either<Failure, void>> call(DeleteDownloadParams params) async {
    try {
      for (final videoId in params.videoIds) {
        final downloads = await localDataSource.getDownloads();
        final item = downloads
            .where((element) => element.videoId == videoId)
            .firstOrNull;

        if (item != null) {
          // Delete file if exists
          if (item.outputPath.isNotEmpty) {
            final file = File(item.outputPath);
            if (await file.exists()) {
              await file.delete();
            }
          }
          // Delete from Hive
          await localDataSource.deleteDownload(videoId);
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete downloads: $e'));
    }
  }
}

class DeleteDownloadParams extends Equatable {
  final List<String> videoIds;

  const DeleteDownloadParams({required this.videoIds});

  @override
  List<Object?> get props => [videoIds];
}
