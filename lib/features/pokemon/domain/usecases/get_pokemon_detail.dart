import '../../../../core/utils/result.dart';
import '../entities/pokemon.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemonDetail {
  final PokemonRepository repository;
  const GetPokemonDetail(this.repository);

  Future<Result<Pokemon>> call(int id) => repository.getPokemonDetail(id);
}
