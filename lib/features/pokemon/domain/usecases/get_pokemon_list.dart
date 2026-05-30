import '../../../../core/utils/result.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemonList {
  final PokemonRepository repository;
  const GetPokemonList(this.repository);

  Future<Result<List<({int id, String name})>>> call({
    int limit = 151,
    int offset = 0,
  }) =>
      repository.getPokemonList(limit: limit, offset: offset);
}
