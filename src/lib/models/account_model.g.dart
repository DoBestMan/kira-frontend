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
    secretKey: json['secret_key'] as String,
    encryptedMnemonic: json['encrypted_mnemonic'] as String,
    checksum: json['checksum'] as String,
    networkInfo:
        NetworkInfo.fromJson(json['network_info'] as Map<String, dynamic>),
    hexAddress: json['hex_address'] as String,
    privateKey: json['private_key'] as String,
    publicKey: json['public_key'] as String,
  );
}

Map<String, dynamic> _$AccountModelToJson(AccountModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'algorithm': instance.algorithm,
      'secret_key': instance.secretKey,
      'encrypted_mnemonic': instance.encryptedMnemonic,
      'checksum': instance.checksum,
      'hex_address': instance.hexAddress,
      'private_key': instance.privateKey,
      'public_key': instance.publicKey,
      'network_info': instance.networkInfo.toJson(),
    };
