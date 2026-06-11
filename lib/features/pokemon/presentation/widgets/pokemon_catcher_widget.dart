import 'dart:math';
import 'package:flutter/material.dart';

enum CatchState { idle, catching, caught, failed }

class PokemonCatcherWidget extends StatefulWidget {
  final String pokemonName;

  const PokemonCatcherWidget({super.key, required this.pokemonName});

  @override
  State<PokemonCatcherWidget> createState() => _PokemonCatcherWidgetState();
}

class _PokemonCatcherWidgetState extends State<PokemonCatcherWidget> {
  CatchState _state = CatchState.idle;
  int _attempts = 0;

  Future<void> _throwPokeball() async {
    setState(() => _state = CatchState.catching);

    await Future.delayed(const Duration(seconds: 2));

    final caught = Random().nextBool();
    setState(() {
      _attempts++;
      _state = caught ? CatchState.caught : CatchState.failed;
    });
  }

  void _reset() => setState(() {
        _state = CatchState.idle;
        _attempts = 0;
      });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: switch (_state) {
          CatchState.idle => _IdleView(
              pokemonName: widget.pokemonName,
              onThrow: _throwPokeball,
            ),
          CatchState.catching => _CatchingView(
              pokemonName: widget.pokemonName,
            ),
          CatchState.caught => _CaughtView(
              pokemonName: widget.pokemonName,
              attempts: _attempts,
              onReset: _reset,
            ),
          CatchState.failed => _FailedView(
              pokemonName: widget.pokemonName,
              attempts: _attempts,
              onRetry: _throwPokeball,
              onReset: _reset,
            ),
        },
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  final String pokemonName;
  final VoidCallback onThrow;

  const _IdleView({required this.pokemonName, required this.onThrow});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('⚪', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          'A wild ${pokemonName.toUpperCase()} appeared!',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onThrow,
          icon: const Icon(Icons.catching_pokemon),
          label: const Text('Throw Pokéball'),
        ),
      ],
    );
  }
}

class _CatchingView extends StatelessWidget {
  final String pokemonName;

  const _CatchingView({required this.pokemonName});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Catching ${pokemonName.toUpperCase()}...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Shake... shake... shake...',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _CaughtView extends StatelessWidget {
  final String pokemonName;
  final int attempts;
  final VoidCallback onReset;

  const _CaughtView({
    required this.pokemonName,
    required this.attempts,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🎉', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          '${pokemonName.toUpperCase()} was caught!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Attempts: $attempts',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: onReset,
          child: const Text('Try another'),
        ),
      ],
    );
  }
}

class _FailedView extends StatelessWidget {
  final String pokemonName;
  final int attempts;
  final VoidCallback onRetry;
  final VoidCallback onReset;

  const _FailedView({
    required this.pokemonName,
    required this.attempts,
    required this.onRetry,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('💨', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          '${pokemonName.toUpperCase()} broke free!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Attempts: $attempts',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.catching_pokemon),
              label: const Text('Try again'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onReset,
              child: const Text('Give up'),
            ),
          ],
        ),
      ],
    );
  }
}
