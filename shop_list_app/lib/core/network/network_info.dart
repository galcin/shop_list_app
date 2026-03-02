import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction over network connectivity checks.
/// Consume via [networkInfoProvider] for DI throughout the app.
abstract class NetworkInfo {
  /// Returns `true` when at least one non-`none` connectivity type is active.
  Future<bool> get isConnected;

  /// Emits a new `bool` whenever connectivity changes.
  /// `true` = at least one interface is available, `false` = fully offline.
  Stream<bool> get connectivityStream;
}

/// Production implementation backed by the `connectivity_plus` package.
///
/// `connectivity_plus` ^6.x returns `List<ConnectivityResult>` from both
/// [Connectivity.checkConnectivity] and [Connectivity.onConnectivityChanged].
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  const NetworkInfoImpl({required this.connectivity});

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  @override
  Stream<bool> get connectivityStream {
    return connectivity.onConnectivityChanged.map(_hasConnection);
  }

  /// Returns `true` if any result is not [ConnectivityResult.none].
  static bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}
