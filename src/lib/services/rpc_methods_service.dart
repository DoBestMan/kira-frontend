import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/method.dart';
import 'package:kira_auth/config.dart';

class RPCMethodsService {
  Map<String, Method> getMethods = new Map<String, Method>();
  Map<String, Method> postMethods = new Map<String, Method>();

  Future<void> getRPCMethods() async {
    String apiUrl = await loadInterxURL();

    var data = await http.get(apiUrl + "/rpc_methods");
    var bodyData = json.decode(data.body);

    // Parse Get Methods
    getMethods.addAll({
      // 'GetAccounts': Method.fromJson(bodyData['GET']['/api/cosmos/auth/accounts']),
      'GetBalances': Method.fromJson(bodyData['GET']['/api/cosmos/bank/balances']),
      'GetTotalSupply': Method.fromJson(bodyData['GET']['/api/cosmos/bank/supply']),
      'GetNetworkStatus': Method.fromJson(bodyData['GET']['/api/status']),
      'GetTransactionHash': Method.fromJson(bodyData['GET']['/api/cosmos/txs']),
      'GetFaucet': Method.fromJson(bodyData['GET']['/api/faucet']),
    });

    // Parse Post Methods
    postMethods.addAll({
      'PostTransaction': Method.fromJson(bodyData['POST']['/api/cosmos/txs']),
      'PostTransactionEncode': Method.fromJson(bodyData['POST']['/api/cosmos/txs/encode'])
    });
  }
}
