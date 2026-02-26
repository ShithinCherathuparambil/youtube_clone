import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/paginated_videos.dart';
import '../repositories/video_repository.dart';

class GetHomeVideosParams extends Equatable {
  const GetHomeVideosParams({this.pageToken, this.categoryId});
  final String? pageToken;
  final String? categoryId;

  @override
  List<Object?> get props => [pageToken, categoryId];
}

@lazySingleton
class GetHomeVideos implements UseCase<PaginatedVideos, GetHomeVideosParams> {
  GetHomeVideos(this._repository);

  final VideoRepository _repository;

  Future<Either<Failure, PaginatedVideos>> call(GetHomeVideosParams params) {
    return _repository.getHomeVideos(
      pageToken: params.pageToken,
      categoryId: params.categoryId,
    );
  }
}
