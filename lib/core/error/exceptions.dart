class ServerException implements Exception {
  ServerException(this.message);
  final String message;

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  CacheException(this.message);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class EncryptionException implements Exception {
  EncryptionException(this.message);
  final String message;

  @override
  String toString() => 'EncryptionException: $message';
}

class ConnectionException implements Exception {
  ConnectionException([this.message = 'No internet connection']);
  final String message;

  @override
  String toString() => 'ConnectionException: $message';
}
