import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:kira_auth/utils/export.dart';
import 'dart:convert';

Future<String> loadConfig() async {
  String rpcUrl = await getInterxRPCUrl();
  if (rpcUrl != '' && rpcUrl != null) {
    return rpcUrl;
  }

  if (rpcUrl.contains('11000') == false) {
    return rpcUrl + ":11000";
  }

  String config = await rootBundle.loadString('assets/config.json');
  rpcUrl = json.decode(config)['api_url'];

  if (rpcUrl.contains('11000') == false) {
    return rpcUrl + ":11000";
  }

  return rpcUrl;
}

Future<String> loadInterxURL() async {
  String url = await loadConfig();

  if (url.contains('http://') == false) {
    url = "http://" + url;
  }

  return url + "/api";
}
