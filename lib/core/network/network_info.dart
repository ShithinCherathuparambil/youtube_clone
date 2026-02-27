import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    try {
      final result = await connectivity.checkConnectivity();
      return result.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      // If the plugin is not found (e.g. missing native implementation after adding package),
      // we fallback to true to allow the app to attempt requests instead of being stuck.
      return true;
    }
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      connectivity.onConnectivityChanged;
}
