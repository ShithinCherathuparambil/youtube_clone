import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube_clone/core/error/failures.dart';
import 'package:youtube_clone/domain/entities/paginated_videos.dart';
import 'package:youtube_clone/domain/entities/video.dart';
import 'package:youtube_clone/domain/repositories/video_repository.dart';
import 'package:youtube_clone/domain/usecases/get_home_videos.dart';

class MockVideoRepository extends Mock implements VideoRepository {}

void main() {
  late MockVideoRepository mockRepository;
  late GetHomeVideos useCase;

  setUp(() {
    mockRepository = MockVideoRepository();
    useCase = GetHomeVideos(mockRepository);
  });

  final tVideos = [
    Video(
      id: 'v1',
      title: 'Test',
      channelName: 'Ch',
      channelId: 'c1',
      thumbnailUrl: 'https://t.co/t',
      videoUrl: 'https://t.co/v',
      duration: const Duration(minutes: 3),
      views: 100,
      publishedAt: DateTime(2024),
    ),
  ];

  const tPaginated = PaginatedVideos(videos: [], nextPageToken: null);

  group('GetHomeVideos UseCase', () {
    test('delegates to repository with correct params', () async {
      when(
        () => mockRepository.getHomeVideos(
          pageToken: any(named: 'pageToken'),
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer((_) async => const Right(tPaginated));

      const params = GetHomeVideosParams(categoryId: '10', pageToken: 'tok1');
      await useCase(params);

      verify(
        () => mockRepository.getHomeVideos(pageToken: 'tok1', categoryId: '10'),
      ).called(1);
    });

    test('returns Right(PaginatedVideos) on success', () async {
      final tResult = PaginatedVideos(videos: tVideos, nextPageToken: 'next');
      when(
        () => mockRepository.getHomeVideos(
          pageToken: any(named: 'pageToken'),
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer((_) async => Right(tResult));

      final result = await useCase(const GetHomeVideosParams());

      expect(result, Right(tResult));
    });

    test('returns Left(ServerFailure) when repository fails', () async {
      when(
        () => mockRepository.getHomeVideos(
          pageToken: any(named: 'pageToken'),
          categoryId: any(named: 'categoryId'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('Network error')));

      final result = await useCase(const GetHomeVideosParams());

      expect(result, const Left(ServerFailure('Network error')));
    });

    test('works with no params (all null)', () async {
      when(
        () => mockRepository.getHomeVideos(pageToken: null, categoryId: null),
      ).thenAnswer((_) async => const Right(tPaginated));

      final result = await useCase(const GetHomeVideosParams());

      expect(result.isRight(), isTrue);
    });
  });
}
