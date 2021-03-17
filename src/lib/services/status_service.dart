import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/node_info.dart';
import 'package:kira_auth/models/sync_info.dart';
import 'package:kira_auth/models/validator_info.dart';
import 'package:kira_auth/config.dart';
import 'package:kira_auth/utils/colors.dart';

class StatusService {
  NodeInfo nodeInfo;
  SyncInfo syncInfo;
  ValidatorInfo validatorInfo;
  String interxPubKey;

  Future<NodeInfo> getNodeStatus() async {
    String apiUrl = await loadInterxURL();

    var data = await http.get(apiUrl + "/kira/status");
    var bodyData = json.decode(data.body);

    nodeInfo = NodeInfo.fromJson(bodyData['node_info']);
    syncInfo = SyncInfo.fromJson(bodyData['sync_info']);
    validatorInfo = ValidatorInfo.fromJson(bodyData['validator_info']);

    data = await http.get(apiUrl + '/status');
    bodyData = json.decode(data.body);
    interxPubKey = bodyData['interx_info']['pub_key']['value'];

    return nodeInfo;
  }

  Future<bool> checkNodeStatus() async {
    String apiUrl = await loadInterxURL();
    print("apiUrl - $apiUrl");
    var response = await http.get(apiUrl + "/kira/status");
    print("Response - ${response.statusCode}");
    if (response.statusCode != 200) return false;
    return true;
  }
}
