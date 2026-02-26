import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/paginated_videos.dart';
import '../repositories/video_repository.dart';
import 'get_home_videos.dart';

@lazySingleton
class GetShorts implements UseCase<PaginatedVideos, GetHomeVideosParams> {
  GetShorts(this._repository);

  final VideoRepository _repository;

  @override
  Future<Either<Failure, PaginatedVideos>> call(GetHomeVideosParams params) {
    return _repository.getShorts(pageToken: params.pageToken);
  }
}
