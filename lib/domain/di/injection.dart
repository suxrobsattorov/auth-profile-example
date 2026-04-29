import 'package:alice/alice.dart';
import 'package:get_it/get_it.dart';

import 'package:auth_profile_example/application/auth/auth_bloc.dart';
import 'package:auth_profile_example/application/profile/profile_bloc.dart';
import 'package:auth_profile_example/domain/interface/auth.dart';
import 'package:auth_profile_example/domain/interface/google_auth.dart';
import 'package:auth_profile_example/domain/interface/profile.dart';
import 'package:auth_profile_example/infrastructure/auth/google_auth_service_impl.dart';
import 'package:auth_profile_example/infrastructure/local/token_storage.dart';
import 'package:auth_profile_example/infrastructure/network/dio_client.dart';
import 'package:auth_profile_example/infrastructure/repository/auth_repository_impl.dart';
import 'package:auth_profile_example/infrastructure/repository/profile_repository_impl.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  _registerAlice();
  _registerStorage();
  _registerServices();
  _registerNetwork();
  _registerRepositories();
  _registerBlocs();
}

void _registerAlice() {
  sl.registerLazySingleton<Alice>(() => Alice());
}

void _registerNetwork() {
  sl.registerLazySingleton<DioClient>(
    () => DioClient(sl<Alice>(), sl<TokenStorage>()),
  );
}

void _registerServices() {
  sl.registerLazySingleton<GoogleAuthService>(() => GoogleAuthServiceImpl());
}

void _registerStorage() {
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
}

void _registerRepositories() {
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositoryImpl(sl<DioClient>()),
  );
}

void _registerBlocs() {
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      repository: sl<IAuthRepository>(),
      googleAuthService: sl<GoogleAuthService>(),
      profileRepository: sl<IProfileRepository>(),
      storage: sl<TokenStorage>(),
    ),
  );
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      repository: sl<IProfileRepository>(),
    ),
  );
}
