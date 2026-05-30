import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_local_datasource.dart';
import '../datasources/pokemon_remote_datasource.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonRemoteDatasource remoteDatasource;
  final PokemonLocalDatasource localDatasource;

  const PokemonRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Result<List<({int id, String name})>>> getPokemonList({
    int limit = 151,
    int offset = 0,
  }) async {
    try {
      final cached = await localDatasource.getCachedPokemonList();
      return Success(cached);
    } on CacheException {
      // cache miss — fetch from network
    }
    try {
      final list = await remoteDatasource.getPokemonList(
        limit: limit,
        offset: offset,
      );
      await localDatasource.cachePokemonList(list);
      return Success(list);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    }
  }

  @override
  Future<Result<Pokemon>> getPokemonDetail(int id) async {
    try {
      final cached = await localDatasource.getCachedPokemonDetail(id);
      return Success(cached);
    } on CacheException {
      // cache miss — fetch from network
    }
    try {
      final pokemon = await remoteDatasource.getPokemonDetail(id);
      await localDatasource.cachePokemonDetail(pokemon);
      return Success(pokemon);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    }
  }
}
