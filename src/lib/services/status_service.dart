import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/node_info.dart';
import 'package:kira_auth/models/sync_info.dart';
import 'package:kira_auth/models/validator_info.dart';
import 'package:kira_auth/config.dart';

class StatusService {
  NodeInfo nodeInfo;
  SyncInfo syncInfo;
  ValidatorInfo validatorInfo;
  String interxPubKey;

  Future<void> getNodeStatus() async {
    String apiUrl = await loadInterxURL();

    var data = await http.get(apiUrl + "/status");
    var bodyData = json.decode(data.body);

    nodeInfo = NodeInfo.fromJson(bodyData['node_info']);
    syncInfo = SyncInfo.fromJson(bodyData['sync_info']);
    validatorInfo = ValidatorInfo.fromJson(bodyData['validator_info']);
    interxPubKey = bodyData['interx_info']['pub_key']['value'];
  }
}
