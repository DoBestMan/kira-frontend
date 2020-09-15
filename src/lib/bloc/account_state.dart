part of 'account_bloc.dart';

@immutable
abstract class AccountState extends Equatable {
  final String message;
  final AccountModel currentAccount;
  final List<AccountModel> accounts;

  AccountState({this.currentAccount, this.accounts, this.message});

  @override
  List<Object> get props => [currentAccount, accounts, message];
}

// Events for getting cached accounts
class AccountInitial extends AccountState {
  AccountInitial() : super();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Account Initial State';
}

class CachedAccountsLoading extends AccountState {
  CachedAccountsLoading() : super();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Get Accounts Loading State';
}

class CachedAccountsLoaded extends AccountState {
  final List<AccountModel> accounts;

  CachedAccountsLoaded({this.accounts}) : super(accounts: accounts);

  @override
  List<Object> get props => [accounts];

  @override
  String toString() => 'Get Accounts Loaded';
}

class CachedAccountsError extends AccountState {
  final String message;

  CachedAccountsError({this.message}) : super(message: message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'Get Accounts Error';
}

// Events for creating a new account
class AccountCreating extends AccountState {
  AccountCreating() : super();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Creating new account';
}

class AccountCreationError extends AccountState {
  final String message;

  AccountCreationError({this.message}) : super(message: message);

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

// Event for updating current account
class CurrentAccountUpdated extends AccountState {
  final AccountModel currentAccount;

  CurrentAccountUpdated({this.currentAccount})
      : super(currentAccount: currentAccount);

  @override
  List<Object> get props => [currentAccount];

  @override
  String toString() => 'Current account updated - ' + currentAccount.name;
}
