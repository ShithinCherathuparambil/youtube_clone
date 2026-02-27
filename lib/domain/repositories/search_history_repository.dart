import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class SearchHistoryRepository {
  Future<Either<Failure, List<String>>> getSearchHistory();
  Future<Either<Failure, void>> addToSearchHistory(String query);
  Future<Either<Failure, void>> removeFromSearchHistory(String query);
  Future<Either<Failure, void>> clearSearchHistory();
}
