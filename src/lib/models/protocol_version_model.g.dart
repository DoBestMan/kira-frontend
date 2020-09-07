// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol_version_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProtocolVersionModel _$ProtocolVersionModelFromJson(Map<String, dynamic> json) {
  return ProtocolVersionModel(
    p2p: json['p2p'] as String,
    block: json['block'] as String,
    app: json['app'] as String,
  );
}

Map<String, dynamic> _$ProtocolVersionModelToJson(
        ProtocolVersionModel instance) =>
    <String, dynamic>{
      'p2p': instance.p2p,
      'block': instance.block,
      'app': instance.app,
    };
