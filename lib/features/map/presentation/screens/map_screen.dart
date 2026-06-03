import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../pokemon/presentation/bloc/pokemon_detail_cubit.dart';
import '../../../pokemon/presentation/screens/detail_screen.dart';
import '../../domain/entities/nearby_pokemon.dart';
import '../bloc/map_cubit.dart';
import '../bloc/map_state.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MapCubit>()..loadMap(),
      child: const _MapScaffold(),
    );
  }
}

class _MapScaffold extends StatelessWidget {
  const _MapScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Pokémon')),
      body: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) => switch (state) {
          MapInitial() => const SizedBox.shrink(),
          MapLoading() => const Center(child: CircularProgressIndicator()),
          MapError(:final message) => _ErrorView(message: message),
          MapLoaded() => _MapView(state: state),
        },
      ),
    );
  }
}

// ── Error ──────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<MapCubit>().loadMap(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map ────────────────────────────────────────────────────────────────────

class _MapView extends StatefulWidget {
  final MapLoaded state;
  const _MapView({required this.state});

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  GoogleMapController? _controller;

  Set<Marker> _buildMarkers(MapLoaded state) {
    return state.nearbyPokemon.map((p) {
      final isSelected = state.selected?.id == p.id;
      return Marker(
        markerId: MarkerId('pokemon_${p.id}'),
        position: LatLng(p.lat, p.lng),
        icon: isSelected
            ? BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              )
            : BitmapDescriptor.defaultMarker,
        onTap: () => context.read<MapCubit>().selectPokemon(p),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final selected = state.selected;
    final panelHeight = 140.0;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: state.userPosition,
            zoom: 15,
          ),
          onMapCreated: (c) => _controller = c,
          markers: _buildMarkers(state),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onTap: (_) => context.read<MapCubit>().clearSelection(),
        ),
        Positioned(
          right: 16,
          bottom: selected != null ? panelHeight + 24 : 24,
          child: FloatingActionButton.small(
            heroTag: 'recenter',
            onPressed: () => _controller?.animateCamera(
              CameraUpdate.newLatLng(state.userPosition),
            ),
            child: const Icon(Icons.my_location),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          bottom: selected != null ? 0 : -panelHeight,
          left: 0,
          right: 0,
          height: panelHeight,
          child: selected != null
              ? _PokemonPanel(pokemon: selected)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Bottom panel ───────────────────────────────────────────────────────────

class _PokemonPanel extends StatelessWidget {
  final NearbyPokemon pokemon;
  const _PokemonPanel({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: pokemon.imageUrl,
            width: 90,
            height: 90,
            placeholder: (_, _) =>
                const SizedBox(width: 90, height: 90, child: Center(child: CircularProgressIndicator())),
            errorWidget: (_, _, _) =>
                const Icon(Icons.catching_pokemon, size: 90),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pokemon.name.capitalized,
                  style: context.titleMedium,
                ),
                Text(
                  '#${pokemon.id.toString().padLeft(3, '0')}',
                  style: context.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          di.sl<PokemonDetailCubit>()..load(pokemon.id),
                      child: DetailScreen(id: pokemon.id, name: pokemon.name),
                    ),
                  ),
                ),
                child: const Text('Details'),
              ),
              TextButton(
                onPressed: () => context.read<MapCubit>().clearSelection(),
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
