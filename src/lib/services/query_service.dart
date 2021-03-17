import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kira_auth/models/account.dart';
import 'package:kira_auth/models/cosmos_account.dart';
import 'package:kira_auth/config.dart';

class QueryService {
  static final httpClient = http.Client();

  static Future<CosmosAccount> getAccountData(Account account) async {
    final String apiUrl = await loadInterxURL();

    final endpoint = apiUrl + "/cosmos/auth/accounts/${account.bech32Address}";
    var response = await httpClient.get(endpoint);

    if (response.statusCode != 200) {
      throw Exception(
        "Expected status code 200 but got ${response.statusCode} - ${response.body}",
      );
    }

    var data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data.containsKey("account")) {
      data = data["account"];
    }

    // var headerData = response.headers;
    // var signature = headerData['interx_signature'];
    return CosmosAccount.fromJson(data);
  }
}
