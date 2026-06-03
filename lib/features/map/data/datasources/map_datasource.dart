import 'dart:math' as math;
import '../../domain/entities/nearby_pokemon.dart';

abstract class MapDatasource {
  Future<List<NearbyPokemon>> getNearbyPokemon(double lat, double lng);
}

class MapDatasourceImpl implements MapDatasource {
  static const _spriteBase =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';

  static const _pool = [
    (id: 1, name: 'bulbasaur'),
    (id: 4, name: 'charmander'),
    (id: 7, name: 'squirtle'),
    (id: 25, name: 'pikachu'),
    (id: 39, name: 'jigglypuff'),
    (id: 52, name: 'meowth'),
    (id: 54, name: 'psyduck'),
    (id: 58, name: 'growlithe'),
    (id: 63, name: 'abra'),
    (id: 74, name: 'geodude'),
    (id: 79, name: 'slowpoke'),
    (id: 92, name: 'gastly'),
    (id: 104, name: 'cubone'),
    (id: 113, name: 'chansey'),
    (id: 131, name: 'lapras'),
    (id: 133, name: 'eevee'),
    (id: 143, name: 'snorlax'),
    (id: 147, name: 'dratini'),
    (id: 149, name: 'dragonite'),
    (id: 150, name: 'mewtwo'),
  ];

  // ~1.5 km radius in degrees
  static const _radiusDeg = 0.014;
  static const _spawnCount = 15;

  @override
  Future<List<NearbyPokemon>> getNearbyPokemon(double lat, double lng) async {
    // Seed from rounded coordinates so the same area shows consistent spawns.
    final seed = (lat * 100).round() * 1000000 + (lng * 100).round();
    final rng = math.Random(seed);

    final shuffled = List.of(_pool)..shuffle(rng);
    final selected = shuffled.take(_spawnCount);

    return selected.map((p) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final dist = rng.nextDouble() * _radiusDeg;
      return NearbyPokemon(
        id: p.id,
        name: p.name,
        imageUrl: '$_spriteBase/${p.id}.png',
        lat: lat + dist * math.cos(angle),
        lng: lng + dist * math.sin(angle),
      );
    }).toList();
  }
}
