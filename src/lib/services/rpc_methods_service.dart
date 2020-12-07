import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/method.dart';
import 'package:kira_auth/config.dart';

class RPCMethodsService {
  Map<String, Method> getMethods = new Map<String, Method>();
  Map<String, Method> postMethods = new Map<String, Method>();

  Future<void> getRPCMethods() async {
    var data = await http.get(apiUrl + "rpc_methods");
    var jsonData = json.decode(data.body);

    // Parse Get Methods
    getMethods.addAll({
      'GetAccounts':
          Method.fromJson(jsonData['GET']['/api/cosmos/auth/accounts']),
      'GetBalances':
          Method.fromJson(jsonData['GET']['/api/cosmos/bank/balances']),
      'GetTotalSupply':
          Method.fromJson(jsonData['GET']['/api/cosmos/bank/supply']),
      'GetNetworkStatus':
          Method.fromJson(jsonData['GET']['/api/cosmos/status']),
      'GetTransactionHash': Method.fromJson(jsonData['GET']['/api/cosmos/txs']),
      'GetFaucet': Method.fromJson(jsonData['GET']['/api/faucet']),
    });

    // Parse Post Methods
    postMethods.addAll({
      'PostTransaction': Method.fromJson(jsonData['POST']['/api/cosmos/txs']),
      'PostTransactionEncode':
          Method.fromJson(jsonData['POST']['/api/cosmos/txs/encode'])
    });
  }
}
