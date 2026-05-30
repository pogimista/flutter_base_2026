import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pokemon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../utils/type_colors.dart';
import '../bloc/pokemon_detail_cubit.dart';
import '../bloc/pokemon_detail_state.dart';

class DetailScreen extends StatelessWidget {
  final int id;
  final String name;

  const DetailScreen({super.key, required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name.capitalized),
      ),
      body: BlocBuilder<PokemonDetailCubit, PokemonDetailState>(
        builder: (context, state) => switch (state) {
          PokemonDetailInitial() => const SizedBox.shrink(),
          PokemonDetailLoading() =>
            const Center(child: CircularProgressIndicator()),
          PokemonDetailLoaded(:final pokemon) => _DetailBody(pokemon: pokemon),
          PokemonDetailError(:final message) =>
            Center(child: Text('Error: $message')),
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Pokemon pokemon;
  const _DetailBody({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        pokemon.types.isNotEmpty ? typeColor(pokemon.types.first) : Colors.grey;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: primaryColor.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: pokemon.imageUrl,
                  height: 180,
                  placeholder: (_, _) => const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, _, _) =>
                      const Icon(Icons.catching_pokemon, size: 180),
                ),
                const SizedBox(height: 8),
                Text(pokemon.formattedId, style: AppTextStyles.detailId),
                Text(pokemon.name.capitalized, style: AppTextStyles.detailName),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      pokemon.types.map((t) => _TypeChip(type: t)).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _InfoTile(label: 'Height', value: pokemon.formattedHeight),
                    _InfoTile(label: 'Weight', value: pokemon.formattedWeight),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Base Stats', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 8),
                ...pokemon.stats.entries.map(
                  (e) => _StatRow(
                    name: e.key,
                    value: e.value,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: typeColor(type),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(type.toUpperCase(), style: AppTextStyles.typeChip),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.infoValue),
        Text(label, style: AppTextStyles.infoLabel),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String name;
  final int value;
  final Color color;
  const _StatRow({required this.name, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(_formatStatName(name), style: AppTextStyles.statLabel),
          ),
          SizedBox(
            width: 36,
            child: Text(value.toString(), style: AppTextStyles.statValue),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 255,
                backgroundColor: AppColors.statBarBg,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatName(String raw) {
    const names = {
      'hp': 'HP',
      'attack': 'Attack',
      'defense': 'Defense',
      'special-attack': 'Sp. Attack',
      'special-defense': 'Sp. Defense',
      'speed': 'Speed',
    };
    return names[raw] ?? raw;
  }
}
