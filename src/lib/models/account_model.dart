import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'dart:convert';

part 'account_model.g.dart';

@JsonSerializable(nullable: false)
class AccountModel {
  String name;
  String version;
  String algorithm;
  String secretKey;
  String encryptedMnemonic;
  String checksum;
  String data;

  AccountModel(
      {@required this.name,
      this.version = 'v0.0.1',
      this.algorithm = 'AES-256',
      @required this.secretKey,
      @required this.encryptedMnemonic,
      this.checksum,
      this.data}) {
    assert(name != null, 'Account name is empty');
    assert(secretKey != null, 'Secret Key is null');
    assert(encryptedMnemonic != null, 'EncryptedMnemonic is null');
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountModelToJson(this);

  factory AccountModel.fromString(String data) {
    Map accMap = json.decode(data);
    return AccountModel.fromJson(accMap);
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
