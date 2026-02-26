import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/playlist.dart';
import '../repositories/video_repository.dart';

class GetPlaylists implements UseCase<List<Playlist>, String> {
  GetPlaylists(this.repository);

  final VideoRepository repository;

  @override
  Future<Either<Failure, List<Playlist>>> call(String channelId) async {
    return await repository.getPlaylists(channelId);
  }
}
