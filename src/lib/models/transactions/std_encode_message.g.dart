// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'std_encode_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StdEncodeMessage _$StdEncodeMessageFromJson(Map<String, dynamic> json) {
  return StdEncodeMessage(
    chainId: json['chain_id'] as String,
    accountNumber: json['account_number'] as String,
    sequence: json['sequence'] as String,
    tx: json['tx'] as StdEncodeTx,
  );
}

Map<String, dynamic> _$StdEncodeMessageToJson(StdEncodeMessage instance) =>
    <String, dynamic>{
      'chain_id': instance.chainId,
      'account_number': instance.accountNumber,
      'sequence': instance.sequence,
      'tx': instance.tx.toJson(),
    };
