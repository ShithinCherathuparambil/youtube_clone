import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/video.dart';

abstract class VideoRepository {
  Future<Either<Failure, List<Video>>> getHomeVideos();
}
