import '../../domain/entities/pokemon.dart';

class PokemonModel extends Pokemon {
  const PokemonModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.types,
    required super.height,
    required super.weight,
    required super.stats,
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    return PokemonModel(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: (json['sprites']['other']['official-artwork']['front_default'] ??
              json['sprites']['front_default'] ??
              '') as String,
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      height: json['height'] as int,
      weight: json['weight'] as int,
      stats: {
        for (final s in json['stats'] as List)
          s['stat']['name'] as String: s['base_stat'] as int,
      },
    );
  }

  factory PokemonModel.fromCache(Map<String, dynamic> json) {
    return PokemonModel(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      types: List<String>.from(json['types'] as List),
      height: json['height'] as int,
      weight: json['weight'] as int,
      stats: Map<String, int>.from(json['stats'] as Map),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'types': types,
        'height': height,
        'weight': weight,
        'stats': stats,
      };
}
