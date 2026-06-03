import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/nearby_pokemon.dart';

sealed class MapState {
  const MapState();
}

final class MapInitial extends MapState {
  const MapInitial();
}

final class MapLoading extends MapState {
  const MapLoading();
}

final class MapLoaded extends MapState {
  final LatLng userPosition;
  final List<NearbyPokemon> nearbyPokemon;
  final NearbyPokemon? selected;

  const MapLoaded({
    required this.userPosition,
    required this.nearbyPokemon,
    this.selected,
  });

  MapLoaded copyWith({NearbyPokemon? selected, bool clearSelected = false}) =>
      MapLoaded(
        userPosition: userPosition,
        nearbyPokemon: nearbyPokemon,
        selected: clearSelected ? null : (selected ?? this.selected),
      );
}

final class MapError extends MapState {
  final String message;
  const MapError(this.message);
}
