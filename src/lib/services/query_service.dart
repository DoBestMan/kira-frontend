import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kira_auth/models/transactions/export.dart';
import 'package:kira_auth/models/account.dart';
import 'package:kira_auth/models/cosmos_account.dart';

class QueryService {
  static final httpClient = http.Client();

  static Future<CosmosAccount> getAccountData(Account account) async {
    final endpoint =
        "${account.networkInfo.lcdUrl}/auth/accounts/${account.bech32Address}";

    final response = await httpClient.get(endpoint);
    if (response.statusCode != 200) {
      throw Exception(
        "Expected status code 200 but got ${response.statusCode} - ${response.body}",
      );
    }

    var json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json.containsKey("result")) {
      json = json["result"];
    }

    final value = json["value"] as Map<String, dynamic>;

    final coins = ((value["coins"] as List) ?? List())
        .map((coinMap) => StdCoin.fromJson(coinMap))
        .toList();

    final accountNumber = value["account_number"] is String
        ? value["account_number"]
        : value["account_number"].toString();

    final sequence = value["sequence"] is String
        ? value["sequence"]
        : value["sequence"].toString();

    final address = value['address'] is String
        ? value['address']
        : value['address'].toString();

    return CosmosAccount(
      address: address,
      accountNumber: accountNumber,
      sequence: sequence,
      coins: coins,
    );
  }
}
