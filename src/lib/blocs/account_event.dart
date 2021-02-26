part of 'account_bloc.dart';

@immutable
abstract class AccountEvent extends Equatable {
  const AccountEvent();
}

class CreateNewAccount extends AccountEvent {
  final String password;
  final String accountName;

  const CreateNewAccount(this.password, this.accountName);

  @override
  List<Object> get props => [];
}

class GetCachedAccounts extends AccountEvent {
  const GetCachedAccounts();

  @override
  List<Object> get props => [];
}

class SetCurrentAccount extends AccountEvent {
  final Account currentAccount;

  const SetCurrentAccount(this.currentAccount);

  @override
  List<Object> get props => [];
}

class SetInterxPubKey extends AccountEvent {
  final String interxPubKey;

  const SetInterxPubKey(this.interxPubKey);

  @override
  List<Object> get props => [];
}
