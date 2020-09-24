import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/method_model.dart';

class RPCMethodsService {
  Map<String, MethodModel> getMethods;
  Map<String, MethodModel> postMethods;

  Future<void> getRPCMethods() async {
    var data = await http.get("http://0.0.0.0:11000/api/rpc_methods");

    var jsonData = json.decode(data.body);

    // Parse Get Methods
    getMethods['/api/cosmos/bank/balances'] = MethodModel.fromJson(
        jsonData['response']['GET']['/api/cosmos/bank/balances']);
    getMethods['/api/cosmos/bank/supply'] = MethodModel.fromJson(
        jsonData['response']['GET']['/api/cosmos/bank/supply']);
    getMethods['/api/cosmos/status'] =
        MethodModel.fromJson(jsonData['response']['GET']['/api/cosmos/status']);
    getMethods['/api/cosmos/tx'] =
        MethodModel.fromJson(jsonData['response']['GET']['/api/cosmos/tx']);

    // Parse Post Methods
    postMethods['/api/cosmos/tx'] =
        MethodModel.fromJson(jsonData['response']['GET']['/api/cosmos/tx']);
  }
}
