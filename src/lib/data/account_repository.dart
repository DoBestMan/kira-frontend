import 'package:shared_preferences/shared_preferences.dart';
import 'package:blake_hash/blake_hash.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'dart:convert';

import 'package:kira_auth/models/network_info.dart';
import 'package:kira_auth/models/account.dart';
import 'package:kira_auth/utils/encrypt.dart';
import 'package:kira_auth/config.dart';

abstract class AccountRepository {
  Future<List<Account>> getAccountsFromCache();
  Future<Account> createNewAccount(String password, String accountName);
  Future<Account> fakeFetchForTesting();
}

class IAccountRepository implements AccountRepository {
  @override
  Future<Account> fakeFetchForTesting() async {
    var config = await loadConfig();
    String apiUrl = json.decode(config)['api_url'];

    return Future.delayed(Duration(seconds: 5), () {
      return Account(
          networkInfo: NetworkInfo(
            bech32Hrp: "kira",
            lcdUrl: apiUrl + "/cosmos",
          ),
          hexAddress: "null",
          privateKey: "null",
          publicKey: "null");
    });
  }

  @override
  Future<List<Account>> getAccountsFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cachedAccountString = prefs.getString('accounts');
    List<Account> accounts = [];

    var array = cachedAccountString.split('---');

    for (int index = 0; index < array.length; index++) {
      if (array[index] != '') {
        accounts.add(Account.fromString(array[index]));
      }
    }

    return accounts;
  }

  @override
  Future<Account> createNewAccount(String password, String accountName) async {
    Account account;

    // Generate Mnemonic for creating a new account
    String mnemonic = bip39.generateMnemonic(strength: 256);
    List<String> wordList = mnemonic.split(' ');
    List<int> bytes = utf8.encode(password);

    var config = await loadConfig();
    String apiUrl = json.decode(config)['api_url'];

    // Get hash value of password and use it to encrypt mnemonic
    var hashDigest = Blake256().update(bytes).digest();

    final networkInfo = NetworkInfo(
      bech32Hrp: "kira",
      lcdUrl: apiUrl + "/cosmos",
    );

    account = Account.derive(wordList, networkInfo);

    account.secretKey = String.fromCharCodes(hashDigest);

    // Encrypt Mnemonic with AES-256 algorithm
    account.encryptedMnemonic = encryptAESCryptoJS(mnemonic, account.secretKey);
    account.checksum = encryptAESCryptoJS('kira', account.secretKey);
    account.name = accountName;

    return account;
  }
}
