import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:kira_auth/models/account.dart';
import 'package:kira_auth/models/transactions/export.dart';

class EncodeTransactionSender {
  static Future<dynamic> broadcastStdEncodeTx({
    @required Account account,
    @required StdEncodeMessage stdEncodeMsg,
  }) async {
    // Get the endpoint
    final apiUrl = "${account.networkInfo.lcdUrl}/txs/encode";

    // Build the request body
    final requestBodyJson = jsonEncode(stdEncodeMsg.toJson());

    // Get the response
    final response = await http.Client().post(apiUrl, body: requestBodyJson);
    if (response.statusCode != 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['message'].contains("decoding bech32 failed")) return "Invalid withdrawal address";

      return "Something went wrong!";
    }

    // Convert the response
    final jsonResponse = jsonDecode(response.body);
    final decoded = base64Decode(jsonResponse['tx']);

    return json.decode(utf8.decode(decoded));
  }
}
