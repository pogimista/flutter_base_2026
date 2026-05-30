import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class PokemonCard extends StatelessWidget {
  final int id;
  final String name;
  final VoidCallback onTap;

  const PokemonCard({
    super.key,
    required this.id,
    required this.name,
    required this.onTap,
  });

  String get _imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  String get _formattedId => '#${id.toString().padLeft(3, '0')}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: _imageUrl,
                  placeholder: (_, _) =>
                      const CircularProgressIndicator(strokeWidth: 2),
                  errorWidget: (_, _, _) =>
                      const Icon(Icons.catching_pokemon, size: 48),
                ),
              ),
              const SizedBox(height: 4),
              Text(_formattedId, style: AppTextStyles.pokemonId),
              Text(
                _capitalized(name),
                style: AppTextStyles.pokemonName,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalized(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
