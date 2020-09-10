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

class SetCurrentAccount extends AccountEvent {
  final String cachedAccountString;
  final String password;

  const SetCurrentAccount(this.cachedAccountString, this.password);

  @override
  List<Object> get props => [cachedAccountString, password];
}

class GetCachedAccounts extends AccountEvent {
  final List<AccountModel> accounts;

  const GetCachedAccounts(this.accounts);
  @override
  List<Object> get props => [];
}
