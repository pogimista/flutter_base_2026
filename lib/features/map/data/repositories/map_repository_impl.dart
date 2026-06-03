import '../../domain/entities/nearby_pokemon.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_datasource.dart';

class MapRepositoryImpl implements MapRepository {
  final MapDatasource _datasource;
  const MapRepositoryImpl(this._datasource);

  @override
  Future<List<NearbyPokemon>> getNearbyPokemon(double lat, double lng) =>
      _datasource.getNearbyPokemon(lat, lng);
}
