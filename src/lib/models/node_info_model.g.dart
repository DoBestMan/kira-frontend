// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Other _$OtherFromJson(Map<String, dynamic> json) {
  return Other(
    txIndex: json['tx_index'] as String,
    rpcAddress: json['rpc_address'] as String,
  );
}

Map<String, dynamic> _$OtherToJson(Other instance) => <String, dynamic>{
      'tx_index': instance.txIndex,
      'rpc_address': instance.rpcAddress,
    };

NodeInfoModel _$NodeInfoModelFromJson(Map<String, dynamic> json) {
  return NodeInfoModel(
    protocolVersion: json['protocol_version'] == null
        ? null
        : ProtocolVersionModel.fromJson(
            json['protocol_version'] as Map<String, dynamic>),
    id: json['id'] as String,
    listenAddress: json['listen_addr'] as String,
    network: json['network'] as String,
    version: json['version'] as String,
    channels: json['channels'] as String,
    moniker: json['moniker'] as String,
    other: json['other'] == null
        ? null
        : Other.fromJson(json['other'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$NodeInfoModelToJson(NodeInfoModel instance) =>
    <String, dynamic>{
      'protocol_version': instance.protocolVersion?.toJson(),
      'id': instance.id,
      'listen_addr': instance.listenAddress,
      'network': instance.network,
      'version': instance.version,
      'channels': instance.channels,
      'moniker': instance.moniker,
      'other': instance.other?.toJson(),
    };
