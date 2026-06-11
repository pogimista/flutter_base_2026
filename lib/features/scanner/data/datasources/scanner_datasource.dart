import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../../domain/entities/scan_result.dart';

abstract class ScannerDatasource {
  Future<ScanResult> classifyImage(File image);
  Future<void> dispose();
}

class ScannerDatasourceImpl implements ScannerDatasource {
  final ImageLabeler _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.5),
  );

  // Maps ML Kit label keywords → Pokémon (lowercase name, national dex ID)
  static const _db = <String, List<({String name, int id})>>{
    'cat': [(name: 'meowth', id: 52), (name: 'persian', id: 53), (name: 'skitty', id: 300)],
    'dog': [(name: 'growlithe', id: 58), (name: 'arcanine', id: 59), (name: 'poochyena', id: 261)],
    'wolf': [(name: 'lycanroc', id: 745), (name: 'mightyena', id: 262), (name: 'absol', id: 359)],
    'fire': [(name: 'charmander', id: 4), (name: 'vulpix', id: 37), (name: 'ponyta', id: 77)],
    'water': [(name: 'squirtle', id: 7), (name: 'psyduck', id: 54), (name: 'totodile', id: 158)],
    'fish': [(name: 'magikarp', id: 129), (name: 'goldeen', id: 118), (name: 'finneon', id: 456)],
    'butterfly': [(name: 'butterfree', id: 12), (name: 'beautifly', id: 267), (name: 'vivillon', id: 666)],
    'snake': [(name: 'ekans', id: 23), (name: 'arbok', id: 24), (name: 'seviper', id: 336)],
    'frog': [(name: 'poliwag', id: 60), (name: 'politoed', id: 186), (name: 'froakie', id: 656)],
    'bird': [(name: 'pidgey', id: 16), (name: 'swellow', id: 277), (name: 'starly', id: 396)],
    'plant': [(name: 'bulbasaur', id: 1), (name: 'oddish', id: 43), (name: 'bellsprout', id: 69)],
    'flower': [(name: 'comfey', id: 764), (name: 'florges', id: 671), (name: 'roselia', id: 315)],
    'turtle': [(name: 'squirtle', id: 7), (name: 'blastoise', id: 9), (name: 'turtwig', id: 387)],
    'bear': [(name: 'teddiursa', id: 216), (name: 'ursaring', id: 217), (name: 'pangoro', id: 675)],
    'mouse': [(name: 'pikachu', id: 25), (name: 'raichu', id: 26), (name: 'rattata', id: 19)],
    'rodent': [(name: 'pikachu', id: 25), (name: 'raichu', id: 26), (name: 'sentret', id: 161)],
    'horse': [(name: 'ponyta', id: 77), (name: 'rapidash', id: 78), (name: 'mudbray', id: 749)],
    'duck': [(name: 'psyduck', id: 54), (name: 'golduck', id: 55), (name: 'ducklett', id: 580)],
    'monkey': [(name: 'mankey', id: 56), (name: 'aipom', id: 190), (name: 'chimchar', id: 390)],
    'rock': [(name: 'geodude', id: 74), (name: 'onix', id: 95), (name: 'rhyhorn', id: 111)],
    'ice': [(name: 'jynx', id: 124), (name: 'lapras', id: 131), (name: 'snorunt', id: 361)],
    'dragon': [(name: 'dratini', id: 147), (name: 'dragonite', id: 149), (name: 'bagon', id: 371)],
    'ghost': [(name: 'gastly', id: 92), (name: 'haunter', id: 93), (name: 'gengar', id: 94)],
    'insect': [(name: 'caterpie', id: 10), (name: 'weedle', id: 13), (name: 'ledyba', id: 165)],
    'bee': [(name: 'beedrill', id: 15), (name: 'combee', id: 415), (name: 'vespiquen', id: 416)],
    'elephant': [(name: 'donphan', id: 232), (name: 'phanpy', id: 231), (name: 'copperajah', id: 879)],
    'crab': [(name: 'krabby', id: 98), (name: 'kingler', id: 99), (name: 'corphish', id: 341)],
    'fox': [(name: 'vulpix', id: 37), (name: 'ninetales', id: 38), (name: 'zorua', id: 570)],
    'cow': [(name: 'miltank', id: 241), (name: 'tauros', id: 128), (name: 'bouffalant', id: 626)],
    'pig': [(name: 'swinub', id: 220), (name: 'tepig', id: 498), (name: 'spoink', id: 325)],
    'penguin': [(name: 'piplup', id: 393), (name: 'empoleon', id: 395), (name: 'delibird', id: 225)],
    'tree': [(name: 'trevenant', id: 709), (name: 'phantump', id: 708), (name: 'sudowoodo', id: 185)],
    'grass': [(name: 'bulbasaur', id: 1), (name: 'chikorita', id: 152), (name: 'snivy', id: 495)],
    'spider': [(name: 'spinarak', id: 167), (name: 'ariados', id: 168), (name: 'joltik', id: 595)],
    'bat': [(name: 'zubat', id: 41), (name: 'golbat', id: 42), (name: 'noibat', id: 714)],
    'deer': [(name: 'stantler', id: 234), (name: 'sawsbuck', id: 586), (name: 'deerling', id: 585)],
    'dinosaur': [(name: 'aerodactyl', id: 142), (name: 'tyrunt', id: 696), (name: 'amaura', id: 698)],
    'chicken': [(name: 'torchic', id: 255), (name: 'blaziken', id: 257), (name: 'fletchling', id: 661)],
    'sheep': [(name: 'mareep', id: 179), (name: 'flaaffy', id: 180), (name: 'ampharos', id: 181)],
    'cactus': [(name: 'cacnea', id: 331), (name: 'cacturne', id: 332)],
    'mushroom': [(name: 'foongus', id: 590), (name: 'amoonguss', id: 591), (name: 'shroomish', id: 285)],
    'lightning': [(name: 'pikachu', id: 25), (name: 'raichu', id: 26), (name: 'zapdos', id: 145)],
    'electric': [(name: 'pikachu', id: 25), (name: 'jolteon', id: 135), (name: 'electabuzz', id: 125)],
  };

  @override
  Future<ScanResult> classifyImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final rawLabels = await _labeler.processImage(inputImage);

    final labels = rawLabels
        .map((l) => ScanLabel(label: l.label, confidence: l.confidence))
        .toList();

    final matched = <MatchedPokemon>{};
    for (final label in rawLabels) {
      final lower = label.label.toLowerCase();
      for (final entry in _db.entries) {
        if (lower.contains(entry.key) || entry.key.contains(lower)) {
          matched.addAll(
            entry.value.map((e) => MatchedPokemon(name: e.name, id: e.id)),
          );
        }
      }
    }

    return ScanResult(labels: labels, matchedPokemon: matched.toList());
  }

  @override
  Future<void> dispose() => _labeler.close();
}
