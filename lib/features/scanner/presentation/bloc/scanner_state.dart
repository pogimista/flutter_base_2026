import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/scan_result.dart';

sealed class ScannerState extends Equatable {
  const ScannerState();
  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {}

class ScannerLoading extends ScannerState {}

class ScannerLoaded extends ScannerState {
  final ScanResult result;
  final File image;

  const ScannerLoaded({required this.result, required this.image});

  @override
  List<Object?> get props => [result, image.path];
}

class ScannerError extends ScannerState {
  final String message;

  const ScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
