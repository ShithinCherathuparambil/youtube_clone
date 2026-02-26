import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/comment.dart';
import '../repositories/video_repository.dart';

@lazySingleton
class GetComments implements UseCase<List<Comment>, GetCommentsParams> {
  GetComments(this._repository);

  final VideoRepository _repository;

  @override
  Future<Either<Failure, List<Comment>>> call(GetCommentsParams params) {
    return _repository.getComments(params.videoId);
  }
}

class GetCommentsParams extends Equatable {
  const GetCommentsParams(this.videoId);

  final String videoId;

  @override
  List<Object?> get props => [videoId];
}
