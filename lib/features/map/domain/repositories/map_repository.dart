import '../entities/nearby_pokemon.dart';

abstract class MapRepository {
  Future<List<NearbyPokemon>> getNearbyPokemon(double lat, double lng);
}
