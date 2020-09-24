// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionResultModel _$TransactionResultModelFromJson(
    Map<String, dynamic> json) {
  return TransactionResultModel(
    code: json['code'] as String,
    data: json['data'] as String,
    log: json['log'] as String,
    codespace: json['codespace'] as String,
    hash: json['hash'] as String,
    error: json['error'] == null
        ? null
        : TransactionError.fromJson(json['error'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TransactionResultModelToJson(
        TransactionResultModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'log': instance.log,
      'codespace': instance.codespace,
      'hash': instance.hash,
      'error': instance.error?.toJson(),
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
