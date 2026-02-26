import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/video_category.dart';
import '../repositories/video_repository.dart';

class GetVideoCategories implements UseCase<List<VideoCategory>, NoParams> {
  GetVideoCategories(this.repository);

  final VideoRepository repository;

  @override
  Future<Either<Failure, List<VideoCategory>>> call(NoParams params) async {
    return await repository.getVideoCategories();
  }
}
