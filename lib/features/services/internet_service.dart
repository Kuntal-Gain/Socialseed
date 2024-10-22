import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Return Stream<ConnectivityResult>, not Stream<List<ConnectivityResult>>
  Stream<List<ConnectivityResult>> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }

  Future<bool> isConnected() async {
    var result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
