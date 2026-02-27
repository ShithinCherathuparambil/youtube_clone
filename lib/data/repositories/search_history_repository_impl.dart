import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/search_history_repository.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  final SharedPreferences sharedPreferences;
  static const String _historyKey = 'search_history';

  SearchHistoryRepositoryImpl({required this.sharedPreferences});

  @override
  Future<Either<Failure, List<String>>> getSearchHistory() async {
    try {
      final history = sharedPreferences.getStringList(_historyKey) ?? [];
      return Right(history);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToSearchHistory(String query) async {
    try {
      if (query.trim().isEmpty) return const Right(null);

      final history = sharedPreferences.getStringList(_historyKey) ?? [];
      // Remove if it already exists to move it to the front
      history.remove(query);
      history.insert(0, query);

      // Limit history to 20 items
      if (history.length > 20) {
        history.removeLast();
      }

      await sharedPreferences.setStringList(_historyKey, history);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromSearchHistory(String query) async {
    try {
      final history = sharedPreferences.getStringList(_historyKey) ?? [];
      history.remove(query);
      await sharedPreferences.setStringList(_historyKey, history);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearSearchHistory() async {
    try {
      await sharedPreferences.remove(_historyKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
