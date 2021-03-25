import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/config.dart';
import 'package:kira_auth/utils/export.dart';

class StatusService {
  NodeInfo nodeInfo;
  SyncInfo syncInfo;
  ValidatorInfo validatorInfo;
  String interxPubKey;
  String rpcUrl = "";

  Future<bool> getNodeStatus() async {
    String apiUrl = await loadInterxURL();
    var config = await loadConfig();
    var response;

    rpcUrl = getIPOnly(apiUrl);
    try {
      response = await http.get(apiUrl + "/kira/status").timeout(Duration(seconds: 3));
    } catch (e) {
      print(e);
      return false;
    }

    if (response.body.contains('node_info') == false && config[0] == true) {
      rpcUrl = getIPOnly(config[1]);
      try {
        response = await http.get(config[1] + "/kira/status").timeout(Duration(seconds: 3));
      } catch (e) {
        return false;
      }

      if (response.body.contains('node_info') == false) {
        return false;
      }
    }

    var bodyData = json.decode(response.body);
    nodeInfo = NodeInfo.fromJson(bodyData['node_info']);
    syncInfo = SyncInfo.fromJson(bodyData['sync_info']);
    validatorInfo = ValidatorInfo.fromJson(bodyData['validator_info']);

    response = await http.get(apiUrl + '/status');

    if (response.body.contains('interx_info') == false && config[0] == true) {
      response = await http.get(config[1] + "/status");
      if (response.body.contains('interx_info') == false) {
        return false;
      }
    }

    bodyData = json.decode(response.body);
    interxPubKey = bodyData['interx_info']['pub_key']['value'];

    return true;
  }

  Future<bool> checkNodeStatus() async {
    String apiUrl = await loadInterxURL();
    var response = await http.get(apiUrl + "/kira/status");
    if (response.statusCode != 200) return false;
    return true;
  }
}
