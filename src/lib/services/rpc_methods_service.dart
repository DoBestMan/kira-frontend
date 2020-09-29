import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/method.dart';

class RPCMethodsService {
  Map<String, Method> getMethods = new Map<String, Method>();
  Map<String, Method> postMethods = new Map<String, Method>();

  Future<void> getRPCMethods() async {
    var data = await http.get("http://0.0.0.0:11000/api/rpc_methods");

    var jsonData = json.decode(data.body);
    print(jsonData);
    // Parse Get Methods
    getMethods.addAll({
      '/api/cosmos/bank/balances': Method.fromJson(
          jsonData['response']['GET']['/api/cosmos/bank/balances']),
      '/api/cosmos/bank/supply': Method.fromJson(
          jsonData['response']['GET']['/api/cosmos/bank/supply']),
      '/api/cosmos/status':
          Method.fromJson(jsonData['response']['GET']['/api/cosmos/status']),
      '/api/cosmos/txs':
          Method.fromJson(jsonData['response']['GET']['/api/cosmos/txs']),
    });

    // Parse Post Methods
    postMethods.addAll({
      '/api/cosmos/txs':
          Method.fromJson(jsonData['response']['POST']['/api/cosmos/txs'])
    });
  }
}
