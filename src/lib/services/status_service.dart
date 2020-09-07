import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/node_info_model.dart';
import 'package:kira_auth/models/sync_info_model.dart';
import 'package:kira_auth/models/validator_info_model.dart';

class StatusService {
  NodeInfoModel nodeInfo;
  SyncInfoModel syncInfo;
  ValidatorInfoModel validatorInfo;

  Future<void> getNodeStatus() async {
    // var data =
    //     await http.get("http://0.0.0.0:11000/api/cosmos/status", headers: {
    //   'Access-Control-Allow-Origin': '*',
    //   'Access-Control-Allow-Methods':
    //       'GET, PUT, POST, DELETE, HEAD, OPTIONS, PATCH',
    //   'Access-Control-Allow-Credentials': 'true',
    //   'Access-Control-Expose-Headers': '*',
    // });

    var data = await http.get("http://0.0.0.0:11000/api/cosmos/status");

    var jsonData = json.decode(data.body);

    nodeInfo = NodeInfoModel.fromJson(jsonData['result']['node_info']);
    syncInfo = SyncInfoModel.fromJson(jsonData['result']['sync_info']);
    validatorInfo =
        ValidatorInfoModel.fromJson(jsonData['result']['validator_info']);
  }
}
