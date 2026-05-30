import 'package:equatable/equatable.dart';

sealed class PokemonListState extends Equatable {
  const PokemonListState();
}

final class PokemonListInitial extends PokemonListState {
  const PokemonListInitial();
  @override
  List<Object?> get props => [];
}

final class PokemonListLoading extends PokemonListState {
  const PokemonListLoading();
  @override
  List<Object?> get props => [];
}

final class PokemonListSuccess extends PokemonListState {
  final List<({int id, String name})> pokemons;
  const PokemonListSuccess(this.pokemons);
  @override
  List<Object?> get props => [pokemons];
}

final class PokemonListFailure extends PokemonListState {
  final String message;
  const PokemonListFailure(this.message);
  @override
  List<Object?> get props => [message];
}
