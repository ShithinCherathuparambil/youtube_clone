import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/security/aes_encryption_service.dart';
import 'data/datasources/download_local_data_source.dart';
import 'data/datasources/download_remote_data_source.dart';
import 'data/datasources/video_remote_data_source.dart';
import 'data/repositories/download_repository_impl.dart';
import 'data/repositories/video_repository_impl.dart';
import 'data/services/background_download_service.dart';
import 'domain/repositories/download_repository.dart';
import 'domain/repositories/video_repository.dart';
import 'data/repositories/firebase_auth_repository_impl.dart';
import 'data/repositories/search_history_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/search_history_repository.dart';
import 'domain/usecases/delete_download.dart';
import 'domain/usecases/get_cached_downloads.dart';
import 'domain/usecases/get_channel_details.dart';
import 'domain/usecases/get_comments.dart';
import 'domain/usecases/get_home_videos.dart';
import 'domain/usecases/get_popular_channels.dart';
import 'domain/usecases/get_playlists.dart';
import 'domain/usecases/get_shorts.dart';
import 'domain/usecases/get_video_categories.dart';
import 'domain/usecases/get_decrypted_file.dart';
import 'domain/usecases/search_videos.dart';
import 'domain/usecases/start_encrypted_download.dart';
import 'core/services/storage_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/theme/theme_cubit.dart';
import 'presentation/bloc/profile/profile_cubit.dart';
import 'presentation/bloc/language/language_cubit.dart';
import 'presentation/bloc/download/download_manager_cubit.dart';
import 'presentation/bloc/video_player/video_player_bloc.dart';
import 'presentation/bloc/search/search_bloc.dart';

final sl = GetIt.instance;

/// Registers app dependencies.
///
/// This project uses GetIt and is structured to be Injectable-ready.
Future<void> init() async {
  sl
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => FlutterLocalNotificationsPlugin())
    ..registerLazySingleton(() => Connectivity())
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()))
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
    ..registerLazySingleton(() => BackgroundDownloadService())
    ..registerLazySingleton(() => StorageService())
    ..registerLazySingleton<VideoRepository>(
      () => VideoRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<DownloadRepository>(
      () => DownloadRepositoryImpl(sl(), sl(), sl(), sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepositoryImpl(sl()),
    )
    ..registerLazySingleton<SearchHistoryRepository>(
      () => SearchHistoryRepositoryImpl(sharedPreferences: sl()),
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
    ..registerLazySingleton(() => GetDecryptedFile(sl()))
    ..registerLazySingleton(() => DeleteDownload(sl()))
    ..registerFactory(() => AuthBloc(sl()))
    ..registerFactory(() => ProfileCubit(sl()))
    ..registerFactory(() => ThemeCubit(sl()))
    ..registerFactory(() => LanguageCubit(sl()))
    ..registerFactory(() => VideoPlayerBloc())
    ..registerFactory(() => DownloadManagerCubit(sl(), sl(), sl(), sl(), sl()))
    ..registerFactory(() => SearchBloc(sl(), sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Services
  sl.registerLazySingleton(() => SettingsService(sl()));
  sl.registerLazySingleton(() => UserService(sl()));
}
