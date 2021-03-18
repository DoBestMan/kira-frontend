// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_signature_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoteSignatureMessage _$VoteSignatureMessageFromJson(Map<String, dynamic> json) {
  return VoteSignatureMessage(
    chainId: json['chain_id'] as String,
    accountNumber: json['account_number'] as String,
    sequence: json['sequence'] as String,
    memo: json['memo'] as String,
    fee: json['fee'] == null
        ? null
        : StdFee.fromJson(json['fee'] as Map<String, dynamic>),
    msgs: (json['msgs'] as List)
        ?.map((e) =>
            e == null ? null : MsgVote.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$VoteSignatureMessageToJson(
        VoteSignatureMessage instance) =>
    <String, dynamic>{
      'chain_id': instance.chainId,
      'account_number': instance.accountNumber,
      'sequence': instance.sequence,
      'memo': instance.memo,
      'fee': instance.fee?.toEncodeJson(),
      'msgs': instance.msgs?.map((e) => e?.toEncodeJson())?.toList(),
    };
