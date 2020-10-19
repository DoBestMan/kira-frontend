part of 'token_bloc.dart';

@immutable
abstract class TokenState extends Equatable {
  final String message;
  final Token feeToken;
  final List<Token> tokens;

  TokenState({this.feeToken, this.tokens, this.message});

  @override
  List<Object> get props => [feeToken, tokens, message];
}

// Events for getting cached accounts
class TokenInitial extends TokenState {
  TokenInitial() : super();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Token Initial State';
}

class QueryTokensFinished extends TokenState {
  final List<Token> tokens;

  QueryTokensFinished({this.tokens}) : super(tokens: tokens);

  @override
  List<Object> get props => [tokens];

  @override
  String toString() => 'Tokens are quried - ';
}

class FeeTokenUpdated extends TokenState {
  final Token feeToken;

  FeeTokenUpdated({this.feeToken}) : super(feeToken: feeToken);

  @override
  List<Object> get props => [feeToken];

  @override
  String toString() => 'Fee token updated - ' + feeToken.ticker;
}
