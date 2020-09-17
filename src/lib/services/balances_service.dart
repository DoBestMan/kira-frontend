import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/token_model.dart';

class StatusService {
  TokenModel balance;

  Future<void> getNodeStatus({address}) async {
    var data = await http
        .get("http://0.0.0.0:11000/api/cosmos/bank/balances/$address");

    var jsonData = json.decode(data.body);

    balance = TokenModel.fromJson(jsonData['response']);
  }
}
