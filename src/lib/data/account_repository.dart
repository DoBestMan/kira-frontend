import 'package:shared_preferences/shared_preferences.dart';
import 'package:blake_hash/blake_hash.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'dart:convert';

import 'package:kira_auth/models/network_info_model.dart';
import 'package:kira_auth/models/account_model.dart';
import 'package:kira_auth/utils/encrypt.dart';

abstract class AccountRepository {
  Future<List<AccountModel>> getAccountsFromCache();
  Future<AccountModel> createNewAccount(String password, String accountName);
  Future<AccountModel> fakeFetchForTesting();
}

class IAccountRepository implements AccountRepository {
  @override
  Future<AccountModel> fakeFetchForTesting() async {
    return Future.delayed(Duration(seconds: 5), () {
      return AccountModel(
          networkInfo: NetworkInfo(
            bech32Hrp: "kira",
            lcdUrl: "http://0.0.0.0:11000",
          ),
          hexAddress: "null",
          privateKey: "null",
          publicKey: "null");
    });
  }

  @override
  Future<List<AccountModel>> getAccountsFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cachedAccountString = prefs.getString('accounts');
    List<AccountModel> accounts = List();

    var array = cachedAccountString.split('---');

    for (int index = 0; index < array.length; index++) {
      if (array[index] != '') {
        accounts.add(AccountModel.fromString(array[index]));
      }
    }

    return accounts;
  }

  @override
  Future<AccountModel> createNewAccount(
      String password, String accountName) async {
    AccountModel account;

    // Generate Mnemonic for creating a new account
    String mnemonic = bip39.generateMnemonic();
    List<String> wordList = mnemonic.split(' ');

    List<int> bytes = utf8.encode(password);

    // Get hash value of password and use it to encrypt mnemonic
    var hashDigest = Blake256().update(bytes).digest();

    final networkInfo = NetworkInfo(
      bech32Hrp: "kira",
      lcdUrl: "http://0.0.0.0:11000",
    );

    account = AccountModel.derive(wordList, networkInfo);
    account.secretKey = String.fromCharCodes(hashDigest);

    // Encrypt Mnemonic with AES-256 algorithm
    account.encryptedMnemonic = encryptAESCryptoJS(mnemonic, account.secretKey);
    account.checksum = encryptAESCryptoJS('kira', account.secretKey);
    account.name = accountName;

    return account;
  }
}
