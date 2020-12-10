import 'dart:convert';

import 'package:http/http.dart' as http;
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
    if (json.containsKey("account")) {
      json = json["account"];
    }

    return CosmosAccount.fromJson(json);
  }
}
