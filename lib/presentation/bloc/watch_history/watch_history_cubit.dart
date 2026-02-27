import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/video.dart';
import '../../../domain/usecases/add_to_history.dart';
import '../../../domain/usecases/get_watch_history.dart';

part 'watch_history_state.dart';

class WatchHistoryCubit extends Cubit<WatchHistoryState> {
  final GetWatchHistory _getWatchHistory;
  final AddToHistory _addToHistory;

  WatchHistoryCubit(this._getWatchHistory, this._addToHistory)
    : super(WatchHistoryInitial());

  Future<void> loadHistory() async {
    emit(WatchHistoryLoading());
    final result = await _getWatchHistory(const NoParams());
    result.fold(
      (failure) => emit(WatchHistoryError(failure.message)),
      (history) => emit(WatchHistoryLoaded(history)),
    );
  }

  Future<void> addToHistory(Video video) async {
    final result = await _addToHistory(video);
    result.fold(
      (failure) => emit(WatchHistoryError(failure.message)),
      (_) => loadHistory(), // Refresh history after adding
    );
  }
}
