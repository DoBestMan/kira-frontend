import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadConfig() async {
  return await rootBundle.loadString('assets/config.json');
}
