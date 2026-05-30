import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/pokemon/presentation/bloc/pokemon_list_bloc.dart';
import 'features/pokemon/presentation/bloc/pokemon_list_event.dart';
import 'features/pokemon/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PokemonListBloc>(
      create: (_) => di.sl<PokemonListBloc>()..add(const LoadPokemonList()),
      child: MaterialApp(
        title: 'Pokédex',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
