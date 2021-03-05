// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProtocolVersion _$ProtocolVersionFromJson(Map<String, dynamic> json) {
  return ProtocolVersion(
    p2p: json['p2p'] as String,
    block: json['block'] as String,
    app: json['app'] as String,
  );
}

Map<String, dynamic> _$ProtocolVersionToJson(ProtocolVersion instance) => <String, dynamic>{
      'p2p': instance.p2p,
      'block': instance.block,
      'app': instance.app,
    };
