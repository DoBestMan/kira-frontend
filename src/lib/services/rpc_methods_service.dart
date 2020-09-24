import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/method_model.dart';

class RPCMethodsService {
  Map<String, MethodModel> getMethods = new Map<String, MethodModel>();
  Map<String, MethodModel> postMethods = new Map<String, MethodModel>();

  Future<void> getRPCMethods() async {
    var data = await http.get("http://0.0.0.0:11000/api/rpc_methods");

    var jsonData = json.decode(data.body);

    // Parse Get Methods
    getMethods.addAll({
      '/api/cosmos/bank/balances': MethodModel.fromJson(
          jsonData['response']['GET']['/api/cosmos/bank/balances']),
      '/api/cosmos/bank/supply': MethodModel.fromJson(
          jsonData['response']['GET']['/api/cosmos/bank/supply']),
      '/api/cosmos/status': MethodModel.fromJson(
          jsonData['response']['GET']['/api/cosmos/status']),
      '/api/cosmos/tx':
          MethodModel.fromJson(jsonData['response']['GET']['/api/cosmos/tx']),
    });

    // Parse Post Methods
    postMethods.addAll({
      '/api/cosmos/tx':
          MethodModel.fromJson(jsonData['response']['POST']['/api/cosmos/tx'])
    });
  }
}
