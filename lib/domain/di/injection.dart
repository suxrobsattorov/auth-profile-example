import 'package:alice/alice.dart';
import 'package:get_it/get_it.dart';

import 'package:auth_profile_example/application/auth/auth_bloc.dart';
import 'package:auth_profile_example/domain/interface/auth.dart';
import 'package:auth_profile_example/infrastructure/local/token_storage.dart';
import 'package:auth_profile_example/infrastructure/network/dio_client.dart';
import 'package:auth_profile_example/infrastructure/repository/auth_repository_impl.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  _registerAlice();
  _registerNetwork();
  _registerStorage();
  _registerRepositories();
  _registerBlocs();
}

void _registerAlice() {
  sl.registerLazySingleton<Alice>(() => Alice());
}

void _registerNetwork() {
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<Alice>()));
}

void _registerStorage() {
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
}

void _registerRepositories() {
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(sl<DioClient>()),
  );
}

void _registerBlocs() {
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      repository: sl<IAuthRepository>(),
      storage: sl<TokenStorage>(),
    ),
  );
}
