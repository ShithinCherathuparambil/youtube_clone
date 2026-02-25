import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/video.dart';
import '../repositories/video_repository.dart';

@lazySingleton
class GetHomeVideos implements UseCase<List<Video>, NoParams> {
  GetHomeVideos(this._repository);

  final VideoRepository _repository;

  @override
  Future<Either<Failure, List<Video>>> call(NoParams params) {
    return _repository.getHomeVideos();
  }
}
