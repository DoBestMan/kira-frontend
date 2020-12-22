import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';
import 'package:kira_auth/models/account.dart';
import 'package:kira_auth/data/account_repository.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository accountRepository;

  AccountBloc(this.accountRepository) : super(AccountInitial());

  @override
  Stream<AccountState> mapEventToState(
    AccountEvent event,
  ) async* {
    if (event is GetCachedAccounts) {
      yield* _mapCachedAccountsToState();
    } else if (event is CreateNewAccount) {
      yield* _mapCreateAccountToState(event);
    } else if (event is SetCurrentAccount) {
      yield* _mapCurrentAccountToState(event);
    } else if (event is SetInterxPubKey) {
      yield* _mapInterxPubKeyToState(event);
    }
  }

  Stream<AccountState> _mapCachedAccountsToState() async* {
    yield CachedAccountsLoading();

    final List<Account> availableAccounts = await accountRepository.getAccountsFromCache();

    yield CachedAccountsLoaded(accounts: availableAccounts);
  }

  Stream<AccountState> _mapCreateAccountToState(event) async* {
    yield AccountCreating();

    final Account createdAccount = await accountRepository.createNewAccount(event.password, event.accountName);

    // final Account createdAccount =
    //     await accountRepository.fakeFetchForTesting();

    yield CurrentAccountUpdated(currentAccount: createdAccount);
  }

  Stream<AccountState> _mapCurrentAccountToState(event) async* {
    yield CurrentAccountUpdated(currentAccount: event.currentAccount);
  }

  Stream<AccountState> _mapInterxPubKeyToState(event) async* {
    yield InterxPubKeyUpdated(interxPubKey: event.interxPubKey);
  }
}
