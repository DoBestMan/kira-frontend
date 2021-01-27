import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:kira_auth/data/validator_repository.dart';
import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

part 'validator_event.dart';
part 'validator_state.dart';

class ValidatorBloc extends Bloc<ValidatorEvent, ValidatorState> {
  final ValidatorRepository validatorRepository;

  ValidatorBloc(this.validatorRepository) : super(ValidatorInitial());

  @override
  Stream<ValidatorState> mapEventToState(
      ValidatorEvent event,
      ) async* {
    if (event is GetCachedValidators) {
      yield* _mapFavoriteValidatorsToState(event);
    } else if (event is ToggleFavoriteAddress) {
      yield* _mapToggleFavoriteAddressToState(event);
    }
  }

  Stream<ValidatorState> _mapFavoriteValidatorsToState(event) async* {
    final List<String> favoriteValidators = await validatorRepository.getFavoriteValidatorsFromCache(event.userAddress);
    yield FavoriteValidatorUpdated(favoriteValidators: favoriteValidators);
  }

  Stream<ValidatorState> _mapToggleFavoriteAddressToState(event) async* {
    await validatorRepository.toggleFavoriteValidator(event.address, event.userAddress);
    yield* _mapFavoriteValidatorsToState(event);
  }
}
