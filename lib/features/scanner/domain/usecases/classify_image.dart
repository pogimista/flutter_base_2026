import 'dart:io';
import '../../../../core/utils/result.dart';
import '../entities/scan_result.dart';
import '../repositories/scanner_repository.dart';

class ClassifyImage {
  final ScannerRepository _repository;

  ClassifyImage(this._repository);

  Future<Result<ScanResult>> call(File image) =>
      _repository.classifyImage(image);
}
