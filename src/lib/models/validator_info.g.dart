// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validator_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubKey _$PubKeyFromJson(Map<String, dynamic> json) {
  return PubKey(
    type: json['type'] as String,
    value: json['value'] as String,
  );
}

Map<String, dynamic> _$PubKeyToJson(PubKey instance) => <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
    };

ValidatorInfo _$ValidatorInfoFromJson(Map<String, dynamic> json) {
  return ValidatorInfo(
    address: json['address'] as String,
    pubKey: json['pub_key'] == null ? null : PubKey.fromJson(json['pub_key'] as Map<String, dynamic>),
    votingPower: json['voting_power'] as String,
  );
}

Map<String, dynamic> _$ValidatorInfoToJson(ValidatorInfo instance) => <String, dynamic>{
      'address': instance.address,
      'pub_key': instance.pubKey?.toJson(),
      'voting_power': instance.votingPower,
    };
