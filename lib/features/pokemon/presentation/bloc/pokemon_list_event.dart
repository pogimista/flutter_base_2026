import 'package:equatable/equatable.dart';

sealed class PokemonListEvent extends Equatable {
  const PokemonListEvent();
}

final class LoadPokemonList extends PokemonListEvent {
  const LoadPokemonList();
  @override
  List<Object?> get props => [];
}
