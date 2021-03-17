part of 'network_bloc.dart';

@immutable
abstract class NetworkState extends Equatable {
  final String networkId;

  NetworkState({this.networkId});

  @override
  List<Object> get props => [networkId];
}

// Events for getting cached accounts
class NetworkInitial extends NetworkState {
  NetworkInitial() : super();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Network Initial State';
}

class NetworkIdUpdated extends NetworkState {
  final String networkId;

  NetworkIdUpdated({this.networkId}) : super(networkId: networkId);

  @override
  List<Object> get props => [networkId];

  @override
  String toString() => 'Network Id updated - ' + networkId;
}
