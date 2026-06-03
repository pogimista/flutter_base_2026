import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../models/pokemon_model.dart';

abstract class PokemonRemoteDatasource {
  Future<List<({int id, String name})>> getPokemonList({int limit, int offset});
  Future<PokemonModel> getPokemonDetail(int id);
}

class PokemonRemoteDatasourceImpl implements PokemonRemoteDatasource {
  final Dio _dio;
  PokemonRemoteDatasourceImpl(this._dio);

  @override
  Future<List<({int id, String name})>> getPokemonList({
    int limit = 151,
    int offset = 0,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/pokemon',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final results = res.data!['results'] as List;
      return results.map((r) {
        final url = r['url'] as String;
        final id = int.parse(url.split('/').where((s) => s.isNotEmpty).last);
        return (id: id, name: r['name'] as String);
      }).toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to load Pokémon list');
    }
  }

  @override
  Future<PokemonModel> getPokemonDetail(int id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/pokemon/$id');
      return PokemonModel.fromJson(res.data!);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to load Pokémon #$id');
    }
  }
}
