import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../../../core/utils/string_extensions.dart';
import '../../domain/entities/scan_result.dart';
import '../bloc/scanner_cubit.dart';
import '../bloc/scanner_state.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ScannerCubit>(),
      child: const _ScannerScaffold(),
    );
  }
}

class _ScannerScaffold extends StatelessWidget {
  const _ScannerScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon Scanner')),
      body: BlocBuilder<ScannerCubit, ScannerState>(
        builder: (context, state) => switch (state) {
          ScannerInitial() => _InitialView(
              onPickImage: (source) => _pickAndClassify(context, source),
            ),
          ScannerLoading() => const Center(child: CircularProgressIndicator()),
          ScannerLoaded(:final result, :final image) => _ResultView(
              result: result,
              image: image,
              onReset: context.read<ScannerCubit>().reset,
            ),
          ScannerError(:final message) => _ErrorView(
              message: message,
              onRetry: context.read<ScannerCubit>().reset,
            ),
        },
      ),
    );
  }

  Future<void> _pickAndClassify(
    BuildContext context,
    ImageSource source,
  ) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null || !context.mounted) return;
    context.read<ScannerCubit>().classify(File(picked.path));
  }
}

class _InitialView extends StatelessWidget {
  final void Function(ImageSource) onPickImage;

  const _InitialView({required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.document_scanner_outlined,
              size: 96,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Identify a Pokémon',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Point at a real-world animal or object to find its Pokémon match. Runs entirely on-device.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () => onPickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => onPickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final ScanResult result;
  final File image;
  final VoidCallback onReset;

  const _ResultView({
    required this.result,
    required this.image,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          if (result.labels.isNotEmpty) ...[
            Text(
              'Detected',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: result.labels
                  .take(6)
                  .map(
                    (l) => Chip(
                      label: Text(
                        '${l.label}  ${(l.confidence * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          if (result.hasMatches) ...[
            Text(
              'Pokémon Matches',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...result.matchedPokemon
                .take(6)
                .map((p) => _PokemonMatchTile(pokemon: p)),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No Pokémon matches found.\nTry a clearer photo.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('Scan again'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PokemonMatchTile extends StatelessWidget {
  final MatchedPokemon pokemon;

  const _PokemonMatchTile({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${pokemon.id}.png';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Image.network(
          imageUrl,
          width: 48,
          height: 48,
          errorBuilder: (_, _, _) => const Icon(Icons.catching_pokemon),
        ),
        title: Text(pokemon.name.capitalized),
        subtitle: Text('#${pokemon.id.toString().padLeft(3, '0')}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () =>
            context.push('/pokemon/${pokemon.id}?name=${pokemon.name}'),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
