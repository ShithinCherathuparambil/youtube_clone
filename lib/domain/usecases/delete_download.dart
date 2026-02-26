import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/download_repository.dart';

@lazySingleton
class DeleteDownload implements UseCase<void, DeleteDownloadParams> {
  DeleteDownload(this.repository);

  final DownloadRepository repository;

  @override
  Future<Either<Failure, void>> call(DeleteDownloadParams params) async {
    try {
      for (final videoId in params.videoIds) {
        final result = await repository.deleteDownload(videoId);
        if (result.isLeft()) return result;
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
