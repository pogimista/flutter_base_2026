import '../../../../core/utils/result.dart';
import '../entities/pokemon.dart';

abstract class PokemonRepository {
  Future<Result<List<({int id, String name})>>> getPokemonList({
    int limit,
    int offset,
  });
  Future<Result<Pokemon>> getPokemonDetail(int id);
}
