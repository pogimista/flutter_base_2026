import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../domain/entities/scan_result.dart';
import 'scanner_datasource.dart';

/// On-device Pokemon classifier using a quantized INT8 TFLite model.
/// Falls back to the ML Kit datasource when the model file is not yet present.
class TfliteScannerDatasource implements ScannerDatasource {
  final ScannerDatasource _mlKitFallback;

  static const _inputSize = 224;
  static const _topK = 3;
  static const _confidenceThreshold = 0.6;

  Interpreter? _interpreter;
  List<String>? _labels;
  bool _initAttempted = false;

  TfliteScannerDatasource(this._mlKitFallback);

  Future<void> _ensureInit() async {
    if (_initAttempted) return;
    _initAttempted = true;
    try {
      _interpreter = await Interpreter.fromAsset(
        'models/pokemon_classifier.tflite',
      );
      final raw = await rootBundle.loadString(
        'assets/models/pokemon_labels.txt',
      );
      _labels = raw.trim().split('\n').map((l) => l.trim()).toList();
    } catch (_) {
      // Model not yet generated — ML Kit fallback will be used transparently
    }
  }

  @override
  Future<ScanResult> classifyImage(File image) async {
    await _ensureInit();
    if (_interpreter != null && _labels != null) {
      final result = await _classifyWithTflite(image);
      if (result.hasMatches) return result;
    }
    return _mlKitFallback.classifyImage(image);
  }

  Future<ScanResult> _classifyWithTflite(File imageFile) async {
    final interpreter = _interpreter!;
    final labels = _labels!;

    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return ScanResult(labels: [], matchedPokemon: []);

    final resized = img.copyResize(
      decoded,
      width: _inputSize,
      height: _inputSize,
    );

    // Input tensor: [1, 224, 224, 3] of float32 raw pixel values [0, 255].
    // preprocess_input (→ [-1, 1] scaling) is baked into the model itself.
    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
          },
        ),
      ),
    );

    final output = [List<double>.filled(labels.length, 0.0)];
    interpreter.run(input, output);

    final scores = output[0];
    final indexed = scores.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = indexed
        .take(_topK)
        .where((e) => e.value >= _confidenceThreshold)
        .toList();

    return ScanResult(
      labels: top
          .map((e) => ScanLabel(label: labels[e.key], confidence: e.value))
          .toList(),
      matchedPokemon: top
          .map((e) => MatchedPokemon(name: labels[e.key], id: e.key + 1))
          .toList(),
    );
  }

  @override
  Future<void> dispose() async {
    _interpreter?.close();
    await _mlKitFallback.dispose();
  }
}
