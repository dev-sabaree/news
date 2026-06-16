import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/services/local_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/news/presentation/bloc/news_bloc.dart';
import '../features/auth/data/datasource/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../core/network/dio_client.dart';
import '../features/news/data/datasource/news_remote_datasource.dart';
import '../features/news/data/repositories/news_repository_impl.dart';
import '../features/news/domain/repositories/news_repository.dart';
import '../core/services/connectivity_service.dart';
import '../core/connectivity/connectivity_cubit.dart';
import '../core/localization/localization_service.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageServiceImpl(sl<SharedPreferences>()),
  );
  // Supabase

  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // DataSource

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  // Repository

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );

  // Network

  sl.registerLazySingleton<DioClient>(() => DioClient());

  // News DataSource

  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(sl<DioClient>()),
  );

  // News Repository

  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(
      sl<NewsRemoteDataSource>(),
      sl<LocalStorageService>(),
    ),
  );

  sl.registerFactory<NewsBloc>(
    () => NewsBloc(newsRepository: sl<NewsRepository>()),
  );

  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(sl<Connectivity>()),
  );

  sl.registerLazySingleton<ConnectivityCubit>(
    () => ConnectivityCubit(connectivityService: sl<ConnectivityService>()),
  );

  sl.registerLazySingleton<LocalizationService>(
    () => LocalizationService(sl<SharedPreferences>()),
  );
}
