// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pagination _$PaginationFromJson(Map<String, dynamic> json) {
  return Pagination(
    nextKey: json['nextKey'] as String,
    total: json['total'] as int,
  );
}

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'nextKey': instance.nextKey,
      'total': instance.total,
    };

TokenModel _$TokenModelFromJson(Map<String, dynamic> json) {
  return TokenModel(
    graphicalSymbol: json['graphical_symbol'] as String,
    assetName: json['asset_name'] as String,
    ticker: json['ticker'] as String,
    balance: json['balance'] as String,
    denomination: json['denomination'] as String,
    decimals: json['decimals'] as String,
    pagination: json['pagination'] == null
        ? null
        : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TokenModelToJson(TokenModel instance) =>
    <String, dynamic>{
      'graphical_symbol': instance.graphicalSymbol,
      'asset_name': instance.assetName,
      'ticker': instance.ticker,
      'balance': instance.balance,
      'denomination': instance.denomination,
      'decimals': instance.decimals,
      'pagination': instance.pagination,
    };
