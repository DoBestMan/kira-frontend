import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:kira_auth/models/account.dart';
import 'package:kira_auth/models/transaction_result.dart';
import 'package:kira_auth/models/transactions/export.dart';

class TransactionSender {
  static Future<dynamic> broadcastStdTx({
    @required Account account,
    @required StdTx stdTx,
    String mode = "sync",
  }) async {
    // Get the endpoint
    final apiUrl = "${account.networkInfo.lcdUrl}/txs";

    // Build the request body
    final requestBody = {"tx": stdTx.toJson(), "mode": mode};
    final requestBodyJson = jsonEncode(requestBody);

    print(requestBodyJson);
    // Get the response
    final response = await http.Client().post(apiUrl, body: requestBodyJson);
    if (response.statusCode != 200) {
      throw Exception(
        "Expected status code 200 but got ${response.statusCode} - ${response.body}",
      );
    }

    // Convert the response
    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return _convertJson(json);
  }

  /// Converts the given [json] to a [TransactionResult] object.
  static dynamic _convertJson(Map<String, dynamic> json) {
    Map<String, dynamic> response = json;

    if (response["code"] == null) {
      final rawLogAsString = response["log"].toString();
      String errorMessage = '';
      String data = '';

      if (rawLogAsString.startsWith('{') &&
          rawLogAsString.contains('message')) {
        errorMessage = jsonDecode(rawLogAsString)['message'];
        data = jsonDecode(rawLogAsString)['data'];
      } else {
        errorMessage = rawLogAsString;
      }

      return TransactionError(
        code: response["code"],
        message: errorMessage,
        data: data,
      );
    }

    return TransactionResult.fromJson(response);
  }
}
