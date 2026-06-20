import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:newsapp/core/services/connectivity_service.dart';
import 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService connectivityService;
  StreamSubscription? _subscription;

  ConnectivityCubit({
    required this.connectivityService,
  }) : super(ConnectivityInitial()) {
    _checkInitialConnection();
    _listenConnectionChanges();
  }

  Future<void> _checkInitialConnection() async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      emit(ConnectivityOnline());
    } else {
      emit(ConnectivityOffline());
    }
  }

  void _listenConnectionChanges() {
    _subscription = connectivityService.onConnectivityChanged.listen((
      result,
    ) {
      if (result.contains(ConnectivityResult.none)) {
        emit(ConnectivityOffline());
      } else {
        emit(ConnectivityOnline());
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}