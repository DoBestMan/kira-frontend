import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:kira_auth/data/token_repository.dart';
import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';
import 'package:kira_auth/models/export.dart';

part 'token_event.dart';
part 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final TokenRepository tokenRepository;

  TokenBloc(this.tokenRepository) : super(TokenInitial());

  @override
  Stream<TokenState> mapEventToState(
    TokenEvent event,
  ) async* {
    if (event is QueryTokens) {
      yield* _mapQueriedTokensToState(event);
    } else if (event is SetFeeToken) {
      yield* _mapFeeTokenToState(event);
    }
  }

  Stream<TokenState> _mapQueriedTokensToState(event) async* {
    final List<Token> quriedTokens =
        await tokenRepository.getTokens(event.address);

    yield QueryTokensFinished(tokens: quriedTokens);
  }

  Stream<TokenState> _mapFeeTokenToState(event) async* {
    final Token feeToken = await tokenRepository.getFeeTokenFromCache();

    yield FeeTokenUpdated(feeToken: feeToken);
  }
}
