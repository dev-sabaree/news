import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:newsapp/core/services/connectivity_service.dart';
import 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService connectivityService;
  StreamSubscription? _subscription;
  int _connectionGeneration = 0;

  ConnectivityCubit({
    required this.connectivityService,
  }) : super(ConnectivityInitial()) {
    _checkInitialConnection();
    _listenConnectionChanges();
  }

  Future<void> _checkInitialConnection() async {
    final generation = ++_connectionGeneration;
    final isConnected = await connectivityService.isConnected();

    if (isClosed || generation != _connectionGeneration) {
      return;
    }

    if (isConnected) {
      emit(ConnectivityOnline());
    } else {
      emit(ConnectivityOffline());
    }
  }

  void _listenConnectionChanges() {
    _subscription = connectivityService.onConnectivityChanged.listen((
      result,
    ) async {
      final generation = ++_connectionGeneration;

      if (result.contains(ConnectivityResult.none)) {
        emit(ConnectivityOffline());
        return;
      }

      final hasInternet = await connectivityService.hasInternetAccess();

      if (isClosed || generation != _connectionGeneration) {
        return;
      }

      if (hasInternet) {
        emit(ConnectivityOnline());
      } else {
        emit(ConnectivityOffline());
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
