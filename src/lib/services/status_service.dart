import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/node_info.dart';
import 'package:kira_auth/models/sync_info.dart';
import 'package:kira_auth/models/validator_info.dart';

class StatusService {
  NodeInfo nodeInfo;
  SyncInfo syncInfo;
  ValidatorInfo validatorInfo;

  Future<void> getNodeStatus() async {
    var data = await http.get("http://0.0.0.0:11000/api/cosmos/status");

    var jsonData = json.decode(data.body);

    nodeInfo = NodeInfo.fromJson(jsonData['node_info']);
    syncInfo = SyncInfo.fromJson(jsonData['sync_info']);
    validatorInfo = ValidatorInfo.fromJson(jsonData['validator_info']);
  }
}
