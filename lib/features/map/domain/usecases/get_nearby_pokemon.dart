import '../entities/nearby_pokemon.dart';
import '../repositories/map_repository.dart';

class GetNearbyPokemon {
  final MapRepository _repository;
  const GetNearbyPokemon(this._repository);

  Future<List<NearbyPokemon>> call(double lat, double lng) =>
      _repository.getNearbyPokemon(lat, lng);
}
