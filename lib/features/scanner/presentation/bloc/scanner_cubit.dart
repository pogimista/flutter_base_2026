import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/classify_image.dart';
import 'scanner_state.dart';

class ScannerCubit extends Cubit<ScannerState> {
  final ClassifyImage _classifyImage;

  ScannerCubit(this._classifyImage) : super(ScannerInitial());

  Future<void> classify(File image) async {
    emit(ScannerLoading());
    final result = await _classifyImage(image);
    switch (result) {
      case Success(:final data):
        emit(ScannerLoaded(result: data, image: image));
      case Err(:final failure):
        emit(ScannerError(failure.message));
    }
  }

  void reset() => emit(ScannerInitial());
}
