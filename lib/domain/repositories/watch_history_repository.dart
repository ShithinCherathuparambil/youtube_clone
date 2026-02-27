import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/video.dart';

abstract class WatchHistoryRepository {
  Future<Either<Failure, void>> addToHistory(Video video);
  Future<Either<Failure, List<Video>>> getWatchHistory();
  Future<Either<Failure, void>> clearHistory();
}
