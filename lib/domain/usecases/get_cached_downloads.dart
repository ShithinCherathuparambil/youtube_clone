import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/download_item.dart';
import '../repositories/download_repository.dart';

@lazySingleton
class GetCachedDownloads implements UseCase<List<DownloadItem>, NoParams> {
  GetCachedDownloads(this._repository);

  final DownloadRepository _repository;

  @override
  Future<Either<Failure, List<DownloadItem>>> call(NoParams params) {
    return _repository.getCachedDownloads();
  }
}
