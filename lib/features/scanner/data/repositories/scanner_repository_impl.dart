import 'dart:io';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/scanner_datasource.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final ScannerDatasource _datasource;

  ScannerRepositoryImpl(this._datasource);

  @override
  Future<Result<ScanResult>> classifyImage(File image) async {
    try {
      final result = await _datasource.classifyImage(image);
      return Success(result);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }
}
