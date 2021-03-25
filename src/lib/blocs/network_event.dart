part of 'network_bloc.dart';

@immutable
abstract class NetworkEvent extends Equatable {
  const NetworkEvent();
}

class SetNetworkInfo extends NetworkEvent {
  final String networkId;
  final String nodeAddress;

  const SetNetworkInfo(this.networkId, this.nodeAddress);

  @override
  List<Object> get props => [];
}
