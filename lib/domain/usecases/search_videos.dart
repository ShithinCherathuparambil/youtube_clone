import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/paginated_videos.dart';
import '../repositories/video_repository.dart';

@lazySingleton
class SearchVideos implements UseCase<PaginatedVideos, SearchVideosParams> {
  SearchVideos(this._repository);

  final VideoRepository _repository;

  @override
  Future<Either<Failure, PaginatedVideos>> call(SearchVideosParams params) {
    return _repository.searchVideos(params.query, pageToken: params.pageToken);
  }
}

class SearchVideosParams extends Equatable {
  const SearchVideosParams({required this.query, this.pageToken});

  final String query;
  final String? pageToken;

  @override
  List<Object?> get props => [query, pageToken];
}
