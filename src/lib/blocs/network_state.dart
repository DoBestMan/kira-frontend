part of 'network_bloc.dart';

@immutable
abstract class NetworkState extends Equatable {
  final String networkId;
  final String nodeAddress;

  NetworkState({this.networkId, this.nodeAddress});

  @override
  List<Object> get props => [networkId, nodeAddress];
}

// Events for getting cached accounts
class NetworkInitial extends NetworkState {
  NetworkInitial() : super();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Network Initial State';
}

class NetworkInfoUpdated extends NetworkState {
  final String networkId;
  final String nodeAddress;

  NetworkInfoUpdated({this.networkId, this.nodeAddress}) : super(networkId: networkId, nodeAddress: nodeAddress);

  @override
  List<Object> get props => [networkId, nodeAddress];

  @override
  String toString() => 'Network Info updated - ' + networkId + ", " + nodeAddress;
}
