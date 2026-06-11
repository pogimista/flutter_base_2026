import 'package:equatable/equatable.dart';

class ScanLabel extends Equatable {
  final String label;
  final double confidence;

  const ScanLabel({required this.label, required this.confidence});

  @override
  List<Object?> get props => [label, confidence];
}

class MatchedPokemon extends Equatable {
  final String name;
  final int id;

  const MatchedPokemon({required this.name, required this.id});

  @override
  List<Object?> get props => [name, id];
}

class ScanResult extends Equatable {
  final List<ScanLabel> labels;
  final List<MatchedPokemon> matchedPokemon;

  const ScanResult({required this.labels, required this.matchedPokemon});

  bool get hasMatches => matchedPokemon.isNotEmpty;

  @override
  List<Object?> get props => [labels, matchedPokemon];
}
