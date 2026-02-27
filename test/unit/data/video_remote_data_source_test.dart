/// Unit tests for [VideoRemoteDataSourceImpl].
///
/// All HTTP requests are mocked via Mocktail and DioClient is not exercised —
/// only the mapping / exception-conversion logic is tested.

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube_clone/core/error/exceptions.dart';
import 'package:youtube_clone/core/network/dio_client.dart';
import 'package:youtube_clone/data/datasources/video_remote_data_source.dart';
import 'package:youtube_clone/data/models/video_model.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

// Fixtures ──────────────────────────────────────────────────────────────────

const _singleVideoJson = {
  'id': 'abc123',
  'snippet': {
    'title': 'Test Video',
    'channelTitle': 'Test Channel',
    'channelId': 'ch1',
    'publishedAt': '2024-01-15T12:00:00Z',
    'thumbnails': {
      'high': {'url': 'https://img.youtube.com/vi/abc123/hqdefault.jpg'},
    },
  },
  'contentDetails': {'duration': 'PT5M30S'},
  'statistics': {
    'viewCount': '12345',
    'likeCount': '500',
    'commentCount': '80',
  },
};

const _paginatedJson = {
  'items': [_singleVideoJson],
  'nextPageToken': 'tokenXYZ',
};

const _emptyPaginatedJson = {'items': <dynamic>[]};

Response<Map<String, dynamic>> _response(Map<String, dynamic> data) => Response(
  data: data,
  requestOptions: RequestOptions(path: ''),
  statusCode: 200,
);

// ────────────────────────────────────────────────────────────────────────────

void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late VideoRemoteDataSourceImpl dataSource;

  setUpAll(() async {
    // Provide a fake API key so YouTubeApiKeys.apiKey doesn't throw NotInitializedError.
    // dotenv.load(mergeWith:) initialises DotEnv without needing a real .env file.
    await dotenv.load(mergeWith: {'YOUTUBE_API_KEY': 'test_key_for_tests'});
  });

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = VideoRemoteDataSourceImpl(mockDioClient);
  });

  group('VideoRemoteDataSource.getHomeVideos', () {
    test('returns PaginatedVideosModel on success', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _response(_paginatedJson));

      final result = await dataSource.getHomeVideos();

      expect(result.videos.length, 1);
      expect(result.nextPageToken, 'tokenXYZ');
      expect(result.videos.first.id, 'abc123');
      expect(result.videos.first.title, 'Test Video');
    });

    test('maps duration correctly (PT5M30S → 330 seconds)', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _response(_paginatedJson));

      final result = await dataSource.getHomeVideos();
      expect(result.videos.first.duration.inSeconds, 330);
    });

    test('maps view count, likes and commentCount from statistics', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _response(_paginatedJson));

      final video = (await dataSource.getHomeVideos()).videos.first;
      expect(video.views, 12345);
      expect(video.likes, 500);
      expect(video.commentCount, 80);
    });

    test('throws ServerException on DioException', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'timeout',
        ),
      );

      expect(() => dataSource.getHomeVideos(), throwsA(isA<ServerException>()));
    });

    test('returns empty videos when items list is empty', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _response(_emptyPaginatedJson));

      final result = await dataSource.getHomeVideos();
      expect(result.videos, isEmpty);
      expect(result.nextPageToken, isNull);
    });

    test('passes pageToken in query parameters when provided', () async {
      Map<String, dynamic>? capturedParams;
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((invocation) async {
        capturedParams =
            invocation.namedArguments[const Symbol('queryParameters')]
                as Map<String, dynamic>?;
        return _response(_emptyPaginatedJson);
      });

      await dataSource.getHomeVideos(pageToken: 'nextPage1');
      expect(capturedParams?['pageToken'], 'nextPage1');
    });
  });

  group('VideoRemoteDataSource.getComments', () {
    const _commentsJson = {
      'items': [
        {
          'snippet': {
            'topLevelComment': {
              'snippet': {
                'authorDisplayName': 'Alice',
                'authorProfileImageUrl': 'https://img/alice.jpg',
                'textDisplay': 'Great video!',
                'likeCount': 10,
                'publishedAt': '2024-01-20T08:00:00Z',
              },
            },
          },
        },
      ],
    };

    test('returns list of CommentModel on success', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _response(_commentsJson));

      final comments = await dataSource.getComments('abc123');
      expect(comments.length, 1);
      expect(comments.first.authorName, 'Alice');
      expect(comments.first.textDisplay, 'Great video!');
    });

    test('throws ServerException on network error', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'error',
        ),
      );

      expect(
        () => dataSource.getComments('abc123'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('VideoRemoteDataSource.searchVideos', () {
    const _searchItem = {
      'id': {'videoId': 'xyz789'},
      'snippet': {
        'title': 'Search Result',
        'channelTitle': 'Channel A',
        'channelId': 'chA',
        'publishedAt': '2024-02-01T00:00:00Z',
        'thumbnails': {
          'high': {'url': 'https://thumb.jpg'},
        },
      },
    };

    test('returns paginated search results on success', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _response({
          'items': [_searchItem],
        }),
      );

      final result = await dataSource.searchVideos('flutter');
      expect(result.videos.length, 1);
      expect((result.videos.first as VideoModel).id, 'xyz789');
    });

    test('throws ServerException on DioException during search', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'err',
        ),
      );

      expect(
        () => dataSource.searchVideos('flutter'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('VideoRemoteDataSource.getChannelDetails', () {
    const _channelJson = {
      'items': [
        {
          'id': 'ch1',
          'snippet': {
            'title': 'My Channel',
            'description': 'A test channel',
            'thumbnails': {
              'high': {'url': 'https://thumb/ch1.jpg'},
            },
            'country': 'US',
            'publishedAt': '2020-01-01T00:00:00Z',
            'customUrl': '@mychannel',
          },
          'statistics': {'subscriberCount': '10000', 'videoCount': '50'},
          'brandingSettings': {
            'image': {'bannerExternalUrl': 'https://banner.jpg'},
          },
        },
      ],
    };

    test('returns ChannelModel on success', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _response(_channelJson));

      final channel = await dataSource.getChannelDetails('ch1');
      expect(channel.id, 'ch1');
      expect(channel.title, 'My Channel');
    });

    test(
      'throws ServerException when channel not found (empty items)',
      () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer((_) async => _response({'items': <dynamic>[]}));

        expect(
          () => dataSource.getChannelDetails('missing'),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
