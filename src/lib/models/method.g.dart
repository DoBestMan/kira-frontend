// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Method _$MethodFromJson(Map<String, dynamic> json) {
  return Method(
    description: json['description'] as String,
    enabled: json['enabled'] as bool,
    rateLimit: (json['rate_limit'] as num)?.toDouble(),
    authRateLimit: (json['auth_rate_limit'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$MethodToJson(Method instance) => <String, dynamic>{
      'description': instance.description,
      'enabled': instance.enabled,
      'rate_limit': instance.rateLimit,
      'auth_rate_limit': instance.authRateLimit,
    };
