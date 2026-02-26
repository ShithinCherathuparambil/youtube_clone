import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/channel.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/paginated_videos.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_remote_data_source.dart';

@LazySingleton(as: VideoRepository)
class VideoRepositoryImpl implements VideoRepository {
  VideoRepositoryImpl(this._remoteDataSource);

  final VideoRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, PaginatedVideos>> getHomeVideos({
    String? pageToken,
  }) async {
    try {
      final result = await _remoteDataSource.getHomeVideos(
        pageToken: pageToken,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error: $e'));
    }
  }

  @override
  Future<Either<Failure, PaginatedVideos>> getShorts({
    String? pageToken,
  }) async {
    try {
      final result = await _remoteDataSource.getShorts(pageToken: pageToken);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getComments(String videoId) async {
    try {
      final result = await _remoteDataSource.getComments(videoId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Channel>>> getPopularChannels() async {
    try {
      final result = await _remoteDataSource.getPopularChannels();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error: $e'));
    }
  }

  @override
  Future<Either<Failure, PaginatedVideos>> searchVideos(
    String query, {
    String? pageToken,
  }) async {
    try {
      final result = await _remoteDataSource.searchVideos(
        query,
        pageToken: pageToken,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error: $e'));
    }
  }
}
