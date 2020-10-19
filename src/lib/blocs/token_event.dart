part of 'token_bloc.dart';

@immutable
abstract class TokenEvent extends Equatable {
  const TokenEvent();
}

class QueryTokens extends TokenEvent {
  final List<Token> tokens;
  const QueryTokens(this.tokens);

  @override
  List<Object> get props => [];
}

class SetFeeToken extends TokenEvent {
  final Token feeToken;
  const SetFeeToken(this.feeToken);

  @override
  List<Object> get props => [];
}
