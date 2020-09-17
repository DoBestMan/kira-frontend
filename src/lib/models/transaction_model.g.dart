// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) {
  return TransactionModel(
    depositAmount: json['deposit_amount'] as String,
    timestamp: json['timestamp'] as String,
    hash: json['hash'] as String,
  );
}

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'deposit_amount': instance.depositAmount,
      'timestamp': instance.timestamp,
      'hash': instance.hash,
    };
