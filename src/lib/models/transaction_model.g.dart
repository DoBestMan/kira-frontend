// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) {
  return TransactionModel(
    token: json['token'] as String,
    hash: json['hash'] as String,
    status: json['status'] as String,
    depositAmount: json['deposit_amount'] as String,
    timestamp: json['timestamp'] as String,
    from: json['from'] as String,
    to: json['to'] as String,
    fee: json['fee'] as String,
  );
}

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'hash': instance.hash,
      'status': instance.status,
      'deposit_amount': instance.depositAmount,
      'timestamp': instance.timestamp,
      'from': instance.from,
      'to': instance.to,
      'fee': instance.fee,
    };
