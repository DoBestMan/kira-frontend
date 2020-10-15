// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return Transaction(
    hash: json['hash'] as String,
    action: json['action'] as String,
    sender: json['sender'] as String,
    recipient: json['recipient'] as String,
    token: json['token'] as String,
    amount: json['amount'] as String,
    module: json['module'] as String,
    gas: json['gas'] as String,
    status: json['status'] as String,
    timestamp: json['timestamp'] as String,
  );
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'action': instance.action,
      'sender': instance.sender,
      'recipient': instance.recipient,
      'token': instance.token,
      'amount': instance.amount,
      'module': instance.module,
      'gas': instance.gas,
      'status': instance.status,
      'timestamp': instance.timestamp,
    };
