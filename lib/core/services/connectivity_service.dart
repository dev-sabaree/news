import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity connectivity;

  ConnectivityService(this.connectivity);

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      connectivity.onConnectivityChanged;

  Future<bool> isConnected() async {
    final result = await connectivity.checkConnectivity();

    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    return hasInternetAccess();
  }

  Future<bool> hasInternetAccess() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 5);

    try {
      final request = await client.headUrl(
        Uri.parse('https://clients3.google.com/generate_204'),
      );

      final response = await request.close();

      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }
}
