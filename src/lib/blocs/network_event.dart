part of 'network_bloc.dart';

@immutable
abstract class NetworkEvent extends Equatable {
  const NetworkEvent();
}

class SetNetworkId extends NetworkEvent {
  final String networkId;
  const SetNetworkId(this.networkId);

  @override
  List<Object> get props => [];
}
