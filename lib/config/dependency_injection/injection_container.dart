import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/environment/environment.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';

// Features - Auth
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Core
  final dio = Dio();
  dio.options.baseUrl = Environment.apiBaseUrl;
  sl.registerLazySingleton(() => dio);

  sl.registerLazySingleton(() => DioClient(dio: sl(), storage: sl()));

  sl.registerLazySingleton(() => NetworkInfo());

  // Features
  _initAuth();
}

void _initAuth() {
  // DataSources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );
}
