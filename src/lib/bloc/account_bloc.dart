import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';
import 'package:kira_auth/models/account_model.dart';
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
      yield CachedAccountsLoading();

      final List<AccountModel> availableAccounts =
          await accountRepository.getAccountsFromCache();

      yield CachedAccountsLoaded(availableAccounts, availableAccounts[0]);
    } else if (event is CreateNewAccount) {
      yield AccountCreating();

      final AccountModel createdAccount = await accountRepository
          .createNewAccount(event.password, event.accountName);

      yield AccountCreated(createdAccount);
    }
  }
}
