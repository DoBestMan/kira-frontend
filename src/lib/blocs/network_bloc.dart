import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:kira_auth/utils/export.dart';

import 'package:equatable/equatable.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  NetworkBloc() : super(NetworkInitial());

  @override
  Stream<NetworkState> mapEventToState(
    NetworkEvent event,
  ) async* {
    if (event is SetNetworkInfo) {
      yield* _mapNetworkInfoToState(event);
    }
  }

  Stream<NetworkState> _mapNetworkInfoToState(event) async* {
    final String networkId = event.networkId == Strings.customNetwork ? Strings.noAvailableNetworks : event.networkId;
    yield NetworkInfoUpdated(networkId: networkId, nodeAddress: event.nodeAddress);
  }
}
