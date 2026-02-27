import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/video.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<Vido> videos;
  final List<String> history;
  final Failure? error;
  final String? nextPageToken;

  const SearchState({
    this.status = SearchStatus.initial,
    this.videos = const [],
    this.history = const [],
    this.error,
    this.nextPageToken,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<Vido>? videos,
    List<String>? history,
    Failure? error,
    String? nextPageToken,
  }) {
    return SearchState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      history: history ?? this.history,
      error: error ?? this.error,
      nextPageToken: nextPageToken ?? this.nextPageToken,
    );
  }

  @override
  List<Object?> get props => [status, videos, history, error, nextPageToken];
}
