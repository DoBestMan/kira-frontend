import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:kira_auth/utils/export.dart';
import 'dart:convert';

Future<String> loadInterxURL() async {
  String rpcUrl = await getInterxRPCUrl();

  if (rpcUrl != null) {
    String protocol = rpcUrl.startsWith('http://')
        ? 'http://'
        : rpcUrl.startsWith('https://')
            ? 'https://'
            : 'http://';

    rpcUrl = rpcUrl.replaceAll('https://', '');
    rpcUrl = rpcUrl.replaceAll('http://', '');
    rpcUrl = rpcUrl.replaceAll('/', '');

    List<String> urlArray = rpcUrl.split(':');

    if (urlArray.length == 2) {
      int port = int.tryParse(urlArray[1]);
      if (port == null || port < 1024 || port > 65535) {
        rpcUrl = urlArray[0] + ':11000';
      }
    } else {
      rpcUrl = rpcUrl + ':11000';
    }

    return protocol + rpcUrl + '/api';
  }

  String config = await rootBundle.loadString('assets/config.json');
  rpcUrl = json.decode(config)['api_url'];

  if (rpcUrl.contains('http://') == false) {
    return "http://" + rpcUrl;
  }

  return rpcUrl + '/api';
}
