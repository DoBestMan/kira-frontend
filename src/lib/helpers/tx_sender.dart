import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:kira_auth/models/account.dart';
import 'package:kira_auth/models/transactions/export.dart';

class TransactionSender {
  static Future<dynamic> broadcastStdTx({
    @required Account account,
    @required StdTx stdTx,
    String mode = "block",
  }) async {
    // Get the endpoint
    final apiUrl = "${account.networkInfo.lcdUrl}/txs";

    // Build the request body
    final requestBody = {"tx": stdTx.toJson(), "mode": mode};
    final requestBodyJson = jsonEncode(requestBody);

    // Get the response
    final response = await http.Client().post(apiUrl, body: requestBodyJson);

    if (response.statusCode != 200) {
      // throw Exception(
      //   "Expected status code 200 but got ${response.statusCode} - ${response.body}",
      // );
      return false;
    }

    // Convert the response
    final json = jsonDecode(response.body);

    return json;
  }
}
