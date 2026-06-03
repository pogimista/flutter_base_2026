import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/nearby_pokemon.dart';
import '../../domain/usecases/get_nearby_pokemon.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final GetNearbyPokemon _getNearbyPokemon;

  MapCubit(this._getNearbyPokemon) : super(const MapInitial());

  Future<void> loadMap() async {
    emit(const MapLoading());
    try {
      final position = await _determinePosition();
      final nearby = await _getNearbyPokemon(
        position.latitude,
        position.longitude,
      );
      emit(MapLoaded(
        userPosition: LatLng(position.latitude, position.longitude),
        nearbyPokemon: nearby,
      ));
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  void selectPokemon(NearbyPokemon pokemon) {
    final current = state;
    if (current is MapLoaded) emit(current.copyWith(selected: pokemon));
  }

  void clearSelection() {
    final current = state;
    if (current is MapLoaded) emit(current.copyWith(clearSelected: true));
  }

  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission denied. Please enable it in app settings.',
      );
    }

    return Geolocator.getCurrentPosition();
  }
}
