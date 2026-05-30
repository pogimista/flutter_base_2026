import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/get_pokemon_list.dart';
import 'pokemon_list_event.dart';
import 'pokemon_list_state.dart';

class PokemonListBloc extends Bloc<PokemonListEvent, PokemonListState> {
  final GetPokemonList _getPokemonList;

  PokemonListBloc(this._getPokemonList) : super(const PokemonListInitial()) {
    on<LoadPokemonList>(_onLoad);
  }

  Future<void> _onLoad(
    LoadPokemonList event,
    Emitter<PokemonListState> emit,
  ) async {
    emit(const PokemonListLoading());
    final result = await _getPokemonList();
    switch (result) {
      case Success(:final data):
        emit(PokemonListSuccess(data));
      case Err(:final failure):
        emit(PokemonListFailure(failure.message));
    }
  }
}
