import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);
  }

  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}
