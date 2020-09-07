// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountModel _$AccountModelFromJson(Map<String, dynamic> json) {
  return AccountModel(
    name: json['name'] as String,
    version: json['version'] as String,
    algorithm: json['algorithm'] as String,
    secretKey: json['secretKey'] as String,
    encryptedMnemonic: json['encryptedMnemonic'] as String,
    checksum: json['checksum'] as String,
    data: json['data'] as String,
  );
}

Map<String, dynamic> _$AccountModelToJson(AccountModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'algorithm': instance.algorithm,
      'secretKey': instance.secretKey,
      'encryptedMnemonic': instance.encryptedMnemonic,
      'checksum': instance.checksum,
      'data': instance.data,
    };
