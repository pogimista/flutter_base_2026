import 'dart:io';
import '../../../../core/utils/result.dart';
import '../entities/scan_result.dart';

abstract class ScannerRepository {
  Future<Result<ScanResult>> classifyImage(File image);
}
