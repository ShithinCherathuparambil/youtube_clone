import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/download_repository.dart';

class GetDecryptedFileParams extends Equatable {
  final String videoId;
  final String encryptedPath;

  const GetDecryptedFileParams({
    required this.videoId,
    required this.encryptedPath,
  });

  @override
  List<Object?> get props => [videoId, encryptedPath];
}

@lazySingleton
class GetDecryptedFile implements UseCase<File, GetDecryptedFileParams> {
  final DownloadRepository _repository;

  GetDecryptedFile(this._repository);

  @override
  Future<Either<Failure, File>> call(GetDecryptedFileParams params) {
    return _repository.getDecryptedFile(params.videoId, params.encryptedPath);
  }
}
