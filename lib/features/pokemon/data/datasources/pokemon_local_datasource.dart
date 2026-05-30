import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../models/pokemon_model.dart';

abstract class PokemonLocalDatasource {
  Future<List<({int id, String name})>> getCachedPokemonList();
  Future<void> cachePokemonList(List<({int id, String name})> list);
  Future<PokemonModel> getCachedPokemonDetail(int id);
  Future<void> cachePokemonDetail(PokemonModel pokemon);
}

class PokemonLocalDatasourceImpl implements PokemonLocalDatasource {
  static const _listKey = 'pokemon_list';
  static const _detailPrefix = 'pokemon_detail_';

  final SharedPreferences prefs;
  const PokemonLocalDatasourceImpl(this.prefs);

  @override
  Future<List<({int id, String name})>> getCachedPokemonList() async {
    final jsonStr = prefs.getString(_listKey);
    if (jsonStr == null) throw const CacheException('No cached Pokémon list');
    final list = jsonDecode(jsonStr) as List;
    return list
        .map((e) => (id: e['id'] as int, name: e['name'] as String))
        .toList();
  }

  @override
  Future<void> cachePokemonList(List<({int id, String name})> list) =>
      prefs.setString(
        _listKey,
        jsonEncode(list.map((e) => {'id': e.id, 'name': e.name}).toList()),
      );

  @override
  Future<PokemonModel> getCachedPokemonDetail(int id) async {
    final jsonStr = prefs.getString('$_detailPrefix$id');
    if (jsonStr == null) {
      throw CacheException('No cached data for Pokémon #$id');
    }
    return PokemonModel.fromCache(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> cachePokemonDetail(PokemonModel pokemon) =>
      prefs.setString('$_detailPrefix${pokemon.id}', jsonEncode(pokemon.toJson()));
}
