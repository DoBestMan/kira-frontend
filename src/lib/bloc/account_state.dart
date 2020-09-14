part of 'account_bloc.dart';

@immutable
abstract class AccountState extends Equatable {
  final String message;
  final AccountModel currentAccount;
  final List<AccountModel> accounts;

  const AccountState({this.currentAccount, this.accounts, this.message});

  @override
  List<Object> get props => [currentAccount, accounts, message];
}

// Events for getting cached accounts
class AccountInitial extends AccountState {
  const AccountInitial();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Account Initial State';
}

class CachedAccountsLoading extends AccountState {
  const CachedAccountsLoading();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Get Accounts Loading State';
}

class CachedAccountsLoaded extends AccountState {
  final AccountModel currentAccount;
  final List<AccountModel> accounts;

  const CachedAccountsLoaded(this.accounts, this.currentAccount);

  @override
  List<Object> get props => [accounts, currentAccount];

  @override
  String toString() => 'Get Accounts Loaded State';
}

class CachedAccountsError extends AccountState {
  final String message;
  const CachedAccountsError(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'Get Accounts Error State';
}

// Events for creating a new account
class AccountCreating extends AccountState {
  const AccountCreating();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Creating new account';
}

class AccountCreated extends AccountState {
  final AccountModel currentAccount;

  const AccountCreated(this.currentAccount);

  @override
  List<Object> get props => [];

  @override
  String toString() => 'New account created';
}

class AccountCreationError extends AccountState {
  final String message;
  const AccountCreationError(this.message);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is AccountCreationError && o.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'Error happened while creating a new account';
}
