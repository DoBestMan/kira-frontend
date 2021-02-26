part of 'validator_bloc.dart';

@immutable
abstract class ValidatorState extends Equatable {
  final List<String> favoriteValidators;

  ValidatorState({this.favoriteValidators});

  @override
  List<Object> get props => [favoriteValidators];
}

// Events for getting cached accounts
class ValidatorInitial extends ValidatorState {
  ValidatorInitial() : super(favoriteValidators: []);

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Validator Initial State';
}

class FavoriteValidatorUpdated extends ValidatorState {
  final List<String> favoriteValidators;

  FavoriteValidatorUpdated({this.favoriteValidators}) : super(favoriteValidators: favoriteValidators);

  @override
  List<Object> get props => [favoriteValidators];

  @override
  String toString() => 'Favorite validators updated - ${favoriteValidators.length}';
}
