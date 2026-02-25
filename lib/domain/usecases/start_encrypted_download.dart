import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/download_item.dart';
import '../repositories/download_repository.dart';

class StartEncryptedDownloadParams {
  const StartEncryptedDownloadParams({
    required this.item,
    required this.onProgress,
  });

  final DownloadItem item;
  final void Function(double progress) onProgress;
}

@lazySingleton
class StartEncryptedDownload
    implements UseCase<DownloadItem, StartEncryptedDownloadParams> {
  StartEncryptedDownload(this._repository);

  final DownloadRepository _repository;

  @override
  Future<Either<Failure, DownloadItem>> call(
    StartEncryptedDownloadParams params,
  ) {
    return _repository.downloadAndEncrypt(
      params.item,
      onProgress: params.onProgress,
    );
  }
}
