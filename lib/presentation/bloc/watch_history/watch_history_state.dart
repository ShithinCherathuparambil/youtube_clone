part of 'watch_history_cubit.dart';

abstract class WatchHistoryState extends Equatable {
  const WatchHistoryState();

  @override
  List<Object?> get props => [];
}

class WatchHistoryInitial extends WatchHistoryState {}

class WatchHistoryLoading extends WatchHistoryState {}

class WatchHistoryLoaded extends WatchHistoryState {
  final List<Video> history;

  const WatchHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class WatchHistoryError extends WatchHistoryState {
  final String message;

  const WatchHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
