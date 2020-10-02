// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionResult _$TransactionResultFromJson(Map<String, dynamic> json) {
  return TransactionResult(
    code: json['code'] as int,
    data: json['data'] as String,
    log: json['log'] as String,
    codespace: json['codespace'] as String,
    hash: json['hash'] as String,
  );
}

Map<String, dynamic> _$TransactionResultToJson(TransactionResult instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'log': instance.log,
      'codespace': instance.codespace,
      'hash': instance.hash,
    };

TransactionError _$TransactionErrorFromJson(Map<String, dynamic> json) {
  return TransactionError(
    code: json['code'] as int,
    data: json['data'] as String,
    message: json['message'] as String,
  );
}

Map<String, dynamic> _$TransactionErrorToJson(TransactionError instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'message': instance.message,
    };
