import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/video.dart';
import '../repositories/watch_history_repository.dart';

@lazySingleton
class AddToHistory implements UseCase<void, Video> {
  final WatchHistoryRepository _repository;

  AddToHistory(this._repository);

  @override
  Future<Either<Failure, void>> call(Video params) {
    return _repository.addToHistory(params);
  }
}
