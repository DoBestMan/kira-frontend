import 'package:flutter/material.dart';
import 'dart:convert';

class AccountData {
  String name;
  String version;
  String algorithm;
  String secretKey;
  String encryptedMnemonic;
  String data;

  AccountData(
      {@required this.name,
      this.version = 'v0.0.1',
      this.algorithm = 'AES-256',
      @required this.secretKey,
      @required this.encryptedMnemonic,
      this.data}) {
    assert(name != null, 'Account name is empty');
    assert(secretKey != null, 'Secret Key is null');
    assert(encryptedMnemonic != null, 'EncryptedMnemonic is null');
  }

  factory AccountData.fromJson(Map<String, dynamic> json) {
    return AccountData(
      name: json['name'] as String,
      version: json['version'] as String,
      algorithm: json['algorithm'] as String,
      secretKey: json['secretKey'] as String,
      encryptedMnemonic: json['encryptedMnemonic'] as String,
      data: json['data'] as String,
    );
  }

  factory AccountData.fromString(String data) {
    Map accMap = json.decode(data);
    return AccountData.fromJson(accMap);
  }

  Map toJson() => {
        'name': name,
        'version': version,
        'algorithm': algorithm,
        'secretKey': secretKey,
        'encryptedMnemonic': encryptedMnemonic,
        'data': data,
      };

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
