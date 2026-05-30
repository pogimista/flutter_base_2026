import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/get_pokemon_detail.dart';
import 'pokemon_detail_state.dart';

class PokemonDetailCubit extends Cubit<PokemonDetailState> {
  final GetPokemonDetail _getPokemonDetail;

  PokemonDetailCubit(this._getPokemonDetail) : super(const PokemonDetailInitial());

  Future<void> load(int id) async {
    emit(const PokemonDetailLoading());
    final result = await _getPokemonDetail(id);
    switch (result) {
      case Success(:final data):
        emit(PokemonDetailLoaded(data));
      case Err(:final failure):
        emit(PokemonDetailError(failure.message));
    }
  }
}
