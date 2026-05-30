import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/pokemon/data/datasources/pokemon_local_datasource.dart';
import '../../features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import '../../features/pokemon/data/repositories/pokemon_repository_impl.dart';
import '../../features/pokemon/domain/repositories/pokemon_repository.dart';
import '../../features/pokemon/domain/usecases/get_pokemon_detail.dart';
import '../../features/pokemon/domain/usecases/get_pokemon_list.dart';
import '../../features/pokemon/presentation/bloc/pokemon_detail_cubit.dart';
import '../../features/pokemon/presentation/bloc/pokemon_list_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerSingleton<http.Client>(http.Client());
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );

  // Data sources
  sl.registerLazySingleton<PokemonRemoteDatasource>(
    () => PokemonRemoteDatasourceImpl(client: sl()),
  );
  sl.registerLazySingleton<PokemonLocalDatasource>(
    () => PokemonLocalDatasourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<PokemonRepository>(
    () => PokemonRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPokemonList(sl()));
  sl.registerLazySingleton(() => GetPokemonDetail(sl()));

  // BLoC / Cubit — factory so each screen gets a fresh instance
  sl.registerFactory(() => PokemonListBloc(sl()));
  sl.registerFactory(() => PokemonDetailCubit(sl()));
}
