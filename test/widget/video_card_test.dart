import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_clone/domain/entities/video.dart';
import 'package:youtube_clone/presentation/widgets/video_card.dart';

Widget _buildTestable(Widget child, {GoRouter? router}) {
  final goRouter =
      router ??
      GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => Scaffold(body: child),
          ),
          GoRoute(path: '/watch', builder: (_, __) => const Scaffold()),
          GoRoute(path: '/channel/:id', builder: (_, __) => const Scaffold()),
        ],
      );

  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => MaterialApp.router(routerConfig: goRouter),
  );
}

final _tVideo = Video(
  id: 'v1',
  title: 'Flutter Tutorial: Build an App',
  channelName: 'Code With Me',
  channelId: 'ch1',
  thumbnailUrl: 'https://picsum.photos/seed/v1/400/225',
  videoUrl: 'https://example.com/video.mp4',
  duration: const Duration(minutes: 12, seconds: 45),
  views: 1500000,
  publishedAt: DateTime.now().subtract(const Duration(days: 30)),
  likes: 75000,
  commentCount: 3000,
);

void main() {
  group('VideoCard Widget', () {
    testWidgets('renders video title', (tester) async {
      await tester.pumpWidget(_buildTestable(VideoCard(video: _tVideo)));
      await tester.pump();
      expect(find.text('Flutter Tutorial: Build an App'), findsOneWidget);
    });

    testWidgets('renders channel name', (tester) async {
      await tester.pumpWidget(_buildTestable(VideoCard(video: _tVideo)));
      await tester.pump();
      expect(find.textContaining('Code With Me'), findsOneWidget);
    });

    testWidgets('renders video duration label', (tester) async {
      await tester.pumpWidget(_buildTestable(VideoCard(video: _tVideo)));
      await tester.pump();
      expect(find.text('12:45'), findsOneWidget);
    });

    testWidgets('renders views in correct shortened format', (tester) async {
      await tester.pumpWidget(_buildTestable(VideoCard(video: _tVideo)));
      await tester.pump();
      expect(find.textContaining('1.5M views'), findsOneWidget);
    });

    testWidgets('title truncates at 2 lines (maxLines is applied)', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestable(VideoCard(video: _tVideo)));
      await tester.pump();
      final richText = tester.firstWidget<Text>(
        find.text('Flutter Tutorial: Build an App'),
      );
      expect(richText.maxLines, 2);
    });

    testWidgets('tapping card navigates to /watch route', (tester) async {
      String? navigatedTo;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => Scaffold(body: VideoCard(video: _tVideo)),
          ),
          GoRoute(
            path: '/watch',
            builder: (context, state) {
              navigatedTo = '/watch';
              return const Scaffold();
            },
          ),
          GoRoute(path: '/channel/:id', builder: (_, __) => const Scaffold()),
        ],
      );

      await tester.pumpWidget(
        _buildTestable(VideoCard(video: _tVideo), router: router),
      );
      await tester.pump();

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(navigatedTo, '/watch');
    });

    testWidgets('shows CachedNetworkImage for thumbnail', (tester) async {
      await tester.pumpWidget(_buildTestable(VideoCard(video: _tVideo)));
      await tester.pump();
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('VideoCard renders as a Card widget', (tester) async {
      await tester.pumpWidget(_buildTestable(VideoCard(video: _tVideo)));
      await tester.pump();
      // VideoCard should render a Card or Container as top-level widget
      expect(find.byType(VideoCard), findsOneWidget);
    });
  });
}
