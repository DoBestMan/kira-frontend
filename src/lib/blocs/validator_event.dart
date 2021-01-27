part of 'validator_bloc.dart';

@immutable
abstract class ValidatorEvent extends Equatable {
  const ValidatorEvent();
}

class GetCachedValidators extends ValidatorEvent {
  final String userAddress;

  const GetCachedValidators(this.userAddress);

  @override
  List<Object> get props => [];
}

class ToggleFavoriteAddress extends ValidatorEvent {
  final String address;
  final String userAddress;

  const ToggleFavoriteAddress(this.address, this.userAddress);

  @override
  List<Object> get props => [];
}
