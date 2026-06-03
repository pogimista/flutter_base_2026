import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/map/data/datasources/map_datasource.dart';
import '../../features/map/data/repositories/map_repository_impl.dart';
import '../../features/map/domain/repositories/map_repository.dart';
import '../../features/map/domain/usecases/get_nearby_pokemon.dart';
import '../../features/map/presentation/bloc/map_cubit.dart';
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
  sl.registerSingleton<Dio>(
    Dio(
      BaseOptions(
        baseUrl: 'https://pokeapi.co/api/v2',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    ),
  );
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );

  // Data sources
  sl.registerLazySingleton<PokemonRemoteDatasource>(
    () => PokemonRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<PokemonLocalDatasource>(
    () => PokemonLocalDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<MapDatasource>(() => MapDatasourceImpl());

  // Repositories
  sl.registerLazySingleton<PokemonRepository>(
    () => PokemonRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
    ),
  );
  sl.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPokemonList(sl()));
  sl.registerLazySingleton(() => GetPokemonDetail(sl()));
  sl.registerLazySingleton(() => GetNearbyPokemon(sl()));

  // BLoC / Cubit — factory so each screen gets a fresh instance
  sl.registerFactory(() => PokemonListBloc(sl()));
  sl.registerFactory(() => PokemonDetailCubit(sl()));
  sl.registerFactory(() => MapCubit(sl()));
}
