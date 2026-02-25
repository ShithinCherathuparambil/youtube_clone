import 'package:equatable/equatable.dart';

/// Base failure object for predictable error boundaries across layers.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class EncryptionFailure extends Failure {
  const EncryptionFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
