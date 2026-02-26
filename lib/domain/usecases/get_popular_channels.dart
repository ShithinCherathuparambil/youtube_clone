import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/channel.dart';
import '../repositories/video_repository.dart';

@lazySingleton
class GetPopularChannels implements UseCase<List<Channel>, NoParams> {
  GetPopularChannels(this._repository);

  final VideoRepository _repository;

  @override
  Future<Either<Failure, List<Channel>>> call(NoParams params) {
    return _repository.getPopularChannels();
  }
}
