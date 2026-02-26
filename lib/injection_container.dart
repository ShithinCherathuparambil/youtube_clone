import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/network/dio_client.dart';
import 'core/security/aes_encryption_service.dart';
import 'data/datasources/download_local_data_source.dart';
import 'data/datasources/download_remote_data_source.dart';
import 'data/datasources/video_remote_data_source.dart';
import 'data/repositories/download_repository_impl.dart';
import 'data/repositories/video_repository_impl.dart';
import 'data/services/background_download_service.dart';
import 'domain/repositories/download_repository.dart';
import 'domain/repositories/video_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'data/repositories/firebase_auth_repository_impl.dart';
import 'domain/usecases/get_cached_downloads.dart';
import 'domain/usecases/get_channel_details.dart';
import 'domain/usecases/get_comments.dart';
import 'domain/usecases/get_home_videos.dart';
import 'domain/usecases/get_popular_channels.dart';
import 'domain/usecases/get_playlists.dart';
import 'domain/usecases/get_shorts.dart';
import 'domain/usecases/get_video_categories.dart';
import 'domain/usecases/search_videos.dart';
import 'domain/usecases/start_encrypted_download.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/download/download_manager_cubit.dart';
import 'presentation/bloc/video_player/video_player_bloc.dart';

final sl = GetIt.instance;

/// Registers app dependencies.
///
/// This project uses GetIt and is structured to be Injectable-ready.
Future<void> init() async {
  sl
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => DioClient())
    ..registerLazySingleton(() => const FlutterSecureStorage())
    ..registerLazySingleton(() => AesEncryptionService(sl()))
    ..registerLazySingleton<VideoRemoteDataSource>(
      () => VideoRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<DownloadRemoteDataSource>(
      () => DownloadRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<DownloadLocalDataSource>(
      () => DownloadLocalDataSourceImpl(),
    )
    ..registerLazySingleton(() => BackgroundDownloadService(sl()))
    ..registerLazySingleton<VideoRepository>(() => VideoRepositoryImpl(sl()))
    ..registerLazySingleton<DownloadRepository>(
      () => DownloadRepositoryImpl(sl(), sl(), sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetComments(sl()))
    ..registerLazySingleton(() => GetChannelDetails(sl()))
    ..registerLazySingleton(() => GetHomeVideos(sl()))
    ..registerLazySingleton(() => GetPopularChannels(sl()))
    ..registerLazySingleton(() => GetShorts(sl()))
    ..registerLazySingleton(() => GetPlaylists(sl()))
    ..registerLazySingleton(() => SearchVideos(sl()))
    ..registerLazySingleton(() => GetVideoCategories(sl()))
    ..registerLazySingleton(() => StartEncryptedDownload(sl()))
    ..registerLazySingleton(() => GetCachedDownloads(sl()))
    ..registerFactory(() => AuthBloc(sl()))
    ..registerFactory(() => VideoPlayerBloc())
    ..registerFactory(() => DownloadManagerCubit(sl(), sl()));
}
