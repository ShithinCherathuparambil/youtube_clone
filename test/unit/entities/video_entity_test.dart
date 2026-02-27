import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_clone/domain/entities/video.dart';

void main() {
  final tPublishedAt = DateTime(2024, 1, 15);

  Video makeVideo({String id = 'v1', String title = 'Test Video'}) => Video(
    id: id,
    title: title,
    channelName: 'Test Channel',
    channelId: 'ch1',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    videoUrl: 'https://example.com/video.mp4',
    duration: const Duration(minutes: 5, seconds: 30),
    views: 1000000,
    publishedAt: tPublishedAt,
    likes: 50000,
    commentCount: 2500,
  );

  group('Video Entity', () {
    test('two instances with same fields should be equal (Equatable)', () {
      final v1 = makeVideo();
      final v2 = makeVideo();
      expect(v1, equals(v2));
    });

    test('two instances with different id should NOT be equal', () {
      final v1 = makeVideo(id: 'v1');
      final v2 = makeVideo(id: 'v2');
      expect(v1, isNot(equals(v2)));
    });

    test('props returns exactly 11 values', () {
      final video = makeVideo();
      expect(video.props.length, 11);
    });

    test('props contains all required fields', () {
      final video = makeVideo();
      expect(
        video.props,
        containsAll([
          'v1',
          'Test Video',
          'Test Channel',
          'ch1',
          'https://example.com/thumb.jpg',
          'https://example.com/video.mp4',
          const Duration(minutes: 5, seconds: 30),
          1000000,
          tPublishedAt,
          50000,
          2500,
        ]),
      );
    });

    test('likes and commentCount default to 0', () {
      final video = Video(
        id: 'x',
        title: 'x',
        channelName: 'x',
        channelId: 'x',
        thumbnailUrl: 'x',
        videoUrl: 'x',
        duration: Duration.zero,
        views: 0,
        publishedAt: DateTime(2024),
      );
      expect(video.likes, 0);
      expect(video.commentCount, 0);
    });
  });
}
