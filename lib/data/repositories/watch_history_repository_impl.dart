import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/watch_history_repository.dart';
import '../datasources/watch_history_local_data_source.dart';
import '../models/watch_history_model.dart';

@LazySingleton(as: WatchHistoryRepository)
class WatchHistoryRepositoryImpl implements WatchHistoryRepository {
  final WatchHistoryLocalDataSource _localDataSource;

  WatchHistoryRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, void>> addToHistory(Video video) async {
    try {
      final model = WatchHistoryModel.fromVideo(video, DateTime.now());
      await _localDataSource.addToHistory(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getWatchHistory() async {
    try {
      final history = await _localDataSource.getWatchHistory();
      return Right(history);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await _localDataSource.clearHistory();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
