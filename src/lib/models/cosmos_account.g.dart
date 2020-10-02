// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cosmos_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CosmosAccount _$CosmosAccountFromJson(Map<String, dynamic> json) {
  return CosmosAccount(
    type: json['@type'] as String ?? '',
    address: json['address'] as String ?? '',
    accountNumber: json['account_number'] as String ?? '',
    sequence: json['sequence'] as String ?? '',
    pubKey: json['pubKey'] as String ?? '',
  );
}

Map<String, dynamic> _$CosmosAccountToJson(CosmosAccount instance) =>
    <String, dynamic>{
      '@type': instance.type,
      'address': instance.address,
      'account_number': instance.accountNumber,
      'sequence': instance.sequence,
      'pubKey': instance.pubKey,
    };
