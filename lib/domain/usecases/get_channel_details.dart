import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/channel.dart';
import '../repositories/video_repository.dart';

class GetChannelDetails implements UseCase<Channel, String> {
  GetChannelDetails(this.repository);

  final VideoRepository repository;

  @override
  Future<Either<Failure, Channel>> call(String channelId) async {
    return await repository.getChannelDetails(channelId);
  }
}
