import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchPerformed extends SearchEvent {
  final String query;
  const SearchPerformed(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchHistoryRequested extends SearchEvent {
  const SearchHistoryRequested();
}

class SearchHistoryRemoved extends SearchEvent {
  final String query;
  const SearchHistoryRemoved(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchHistoryCleared extends SearchEvent {
  const SearchHistoryCleared();
}
