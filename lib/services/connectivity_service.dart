import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static bool _isOnline = true;
  static final _controller = StreamController<bool>.broadcast();

  static bool get isOnline => _isOnline;
  static Stream<bool> get onConnectivityChanged => _controller.stream;

  static Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = !results.contains(ConnectivityResult.none);
    _connectivity.onConnectivityChanged.listen((results) {
      final online = !results.contains(ConnectivityResult.none);
      if (online != _isOnline) {
        _isOnline = online;
        _controller.add(_isOnline);
      }
    });
  }

  static Future<bool> checkNow() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = !results.contains(ConnectivityResult.none);
    return _isOnline;
  }
}

final connectivityProvider = StreamProvider<bool>((ref) {
  return ConnectivityService.onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final stream = ref.watch(connectivityProvider);
  return stream.when(
    data: (online) => online,
    loading: () => ConnectivityService.isOnline,
    error: (_, _) => true,
  );
});
