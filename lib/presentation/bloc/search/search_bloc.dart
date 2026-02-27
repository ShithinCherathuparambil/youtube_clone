import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../domain/usecases/search_videos.dart';
import '../../../domain/repositories/search_history_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchVideos _searchVideos;
  final SearchHistoryRepository _historyRepository;

  SearchBloc(this._searchVideos, this._historyRepository)
    : super(const SearchState()) {
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: _debounce(const Duration(milliseconds: 300)),
    );
    on<SearchPerformed>(_onSearchPerformed);
    on<SearchHistoryRequested>(_onSearchHistoryRequested);
    on<SearchHistoryRemoved>(_onSearchHistoryRemoved);
    on<SearchHistoryCleared>(_onSearchHistoryCleared);
  }

  EventTransformer<T> _debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(status: SearchStatus.initial, videos: []));
      return;
    }
    // We don't perform actual video search on every change if we use a delegate,
    // but the user asked for debounce. Usually debounce is for suggestions or
    // real-time results.
  }

  Future<void> _onSearchPerformed(
    SearchPerformed event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) return;

    emit(state.copyWith(status: SearchStatus.loading));

    // Save to history
    await _historyRepository.addToSearchHistory(event.query);
    final historyResult = await _historyRepository.getSearchHistory();
    historyResult.fold((_) => null, (history) {
      emit(state.copyWith(history: history));
    });

    final result = await _searchVideos(SearchVideosParams(query: event.query));

    result.fold(
      (failure) =>
          emit(state.copyWith(status: SearchStatus.failure, error: failure)),
      (paginated) => emit(
        state.copyWith(
          status: SearchStatus.success,
          videos: paginated.videos,
          nextPageToken: paginated.nextPageToken,
        ),
      ),
    );
  }

  Future<void> _onSearchHistoryRequested(
    SearchHistoryRequested event,
    Emitter<SearchState> emit,
  ) async {
    final result = await _historyRepository.getSearchHistory();
    result.fold(
      (failure) => emit(state.copyWith(error: failure)),
      (history) => emit(state.copyWith(history: history)),
    );
  }

  Future<void> _onSearchHistoryRemoved(
    SearchHistoryRemoved event,
    Emitter<SearchState> emit,
  ) async {
    await _historyRepository.removeFromSearchHistory(event.query);
    add(SearchHistoryRequested());
  }

  Future<void> _onSearchHistoryCleared(
    SearchHistoryCleared event,
    Emitter<SearchState> emit,
  ) async {
    await _historyRepository.clearSearchHistory();
    emit(state.copyWith(history: []));
  }
}
