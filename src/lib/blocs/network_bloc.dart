import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  NetworkBloc() : super(NetworkInitial());

  @override
  Stream<NetworkState> mapEventToState(
    NetworkEvent event,
  ) async* {
    if (event is SetNetworkId) {
      yield* _mapNetworkIdToState(event);
    }
  }

  Stream<NetworkState> _mapNetworkIdToState(event) async* {
    String networkId = event.networkId == 'Custom Network' ? "No Network" : event.networkId;
    yield NetworkIdUpdated(networkId: networkId);
  }
}
