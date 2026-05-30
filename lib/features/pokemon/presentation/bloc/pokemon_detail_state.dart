import 'package:equatable/equatable.dart';
import '../../domain/entities/pokemon.dart';

sealed class PokemonDetailState extends Equatable {
  const PokemonDetailState();
}

final class PokemonDetailInitial extends PokemonDetailState {
  const PokemonDetailInitial();
  @override
  List<Object?> get props => [];
}

final class PokemonDetailLoading extends PokemonDetailState {
  const PokemonDetailLoading();
  @override
  List<Object?> get props => [];
}

final class PokemonDetailLoaded extends PokemonDetailState {
  final Pokemon pokemon;
  const PokemonDetailLoaded(this.pokemon);
  @override
  List<Object?> get props => [pokemon];
}

final class PokemonDetailError extends PokemonDetailState {
  final String message;
  const PokemonDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
