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
                Text(pokemon.formattedId, style: context.labelSmall),
                Text(pokemon.name.capitalized, style: context.headlineMedium),
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
                Text('Base Stats', style: context.titleMedium),
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
      child: Text(
        type.toUpperCase(),
        style: context.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
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
        Text(value, style: context.titleLarge),
        Text(label, style: context.bodySmall),
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
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => showDialog(
        context: context,
        builder: (_) => _StatDialog(name: name, value: value, color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(
                _formatStatName(name),
                style: context.labelMedium.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 36,
              child: Text(value.toString(), style: context.labelMedium),
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

// ── Stat dialog ────────────────────────────────────────────────────────────

class _StatDialog extends StatelessWidget {
  final String name;
  final int value;
  final Color color;

  const _StatDialog({
    required this.name,
    required this.value,
    required this.color,
  });

  static const _descriptions = {
    'hp': 'Hit Points — determines how much damage a Pokémon can receive before fainting.',
    'attack': 'Determines the power of physical moves such as Tackle and Slash.',
    'defense': 'Reduces the damage received from physical moves.',
    'special-attack': 'Determines the power of special moves such as Flamethrower and Thunderbolt.',
    'special-defense': 'Reduces the damage received from special moves.',
    'speed': 'Determines which Pokémon acts first each turn. Higher is faster.',
  };

  static const _labels = {
    'hp': 'HP',
    'attack': 'Attack',
    'defense': 'Defense',
    'special-attack': 'Sp. Attack',
    'special-defense': 'Sp. Defense',
    'speed': 'Speed',
  };

  @override
  Widget build(BuildContext context) {
    final label = _labels[name] ?? name;
    final description = _descriptions[name] ?? 'No description available.';
    final rating = _rating(value);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$value / 255', style: Theme.of(context).textTheme.labelMedium),
              Text(
                rating,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 255,
              backgroundColor: AppColors.statBarBg,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    );
  }

  String _rating(int v) {
    if (v >= 150) return 'Exceptional';
    if (v >= 100) return 'Great';
    if (v >= 70) return 'Good';
    if (v >= 40) return 'Average';
    return 'Low';
  }
}
