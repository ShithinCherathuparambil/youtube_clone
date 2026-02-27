import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/error/failures.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
import '../bloc/search/search_state.dart';
import '../widgets/video_card.dart';
import '../widgets/error_view.dart';
import '../widgets/connection_error_view.dart';

class CustomSearchDelegate extends SearchDelegate<String?> {
  final SearchBloc searchBloc;

  CustomSearchDelegate(this.searchBloc);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) return const SizedBox.shrink();

    searchBloc.add(SearchPerformed(query));

    return BlocBuilder<SearchBloc, SearchState>(
      bloc: searchBloc,
      builder: (context, state) {
        if (state.status == SearchStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == SearchStatus.failure) {
          final error = state.error;
          if (error is ConnectionFailure) {
            return ConnectionErrorView(
              onRetry: () => searchBloc.add(SearchPerformed(query)),
            );
          }
          return ErrorView(
            message: error?.message ?? 'An error occurred',
            onRetry: () => searchBloc.add(SearchPerformed(query)),
          );
        }

        if (state.status == SearchStatus.success) {
          if (state.videos.isEmpty) {
            return Center(child: Text('No results found for "$query"'));
          }
          return ListView.builder(
            itemCount: state.videos.length,
            itemBuilder: (context, index) {
              return VideoCard(video: state.videos[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    searchBloc.add(const SearchHistoryRequested());

    return BlocBuilder<SearchBloc, SearchState>(
      bloc: searchBloc,
      builder: (context, state) {
        final history = state.history
            .where((h) => h.toLowerCase().contains(query.toLowerCase()))
            .toList();

        if (history.isEmpty && query.isEmpty) {
          return const Center(child: Text('Search history is empty'));
        }

        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(item),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  searchBloc.add(SearchHistoryRemoved(item));
                },
              ),
              onTap: () {
                query = item;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}
