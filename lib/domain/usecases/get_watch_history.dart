import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/video.dart';
import '../repositories/watch_history_repository.dart';

@lazySingleton
class GetWatchHistory implements UseCase<List<Video>, NoParams> {
  final WatchHistoryRepository _repository;

  GetWatchHistory(this._repository);

  @override
  Future<Either<Failure, List<Video>>> call(NoParams params) {
    return _repository.getWatchHistory();
  }
}
