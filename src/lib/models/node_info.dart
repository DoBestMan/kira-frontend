import 'package:kira_auth/models/protocol_version.dart';
import 'package:json_annotation/json_annotation.dart';

part 'node_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Other {
  final String txIndex;
  final String rpcAddress;

  Other({this.txIndex, this.rpcAddress}) {
    assert(this.txIndex != null || this.rpcAddress != null);
  }

  factory Other.fromJson(Map<String, dynamic> json) => _$OtherFromJson(json);

  Map<String, dynamic> toJson() => _$OtherToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class NodeInfo {
  ProtocolVersion protocolVersion;
  final String id;
  @JsonKey(name: 'listen_addr')
  final String listenAddress;
  final String network;
  final String version;
  final String channels;
  final String moniker;
  Other other;

  NodeInfo(
      {this.protocolVersion,
      this.id,
      this.listenAddress,
      this.network,
      this.version,
      this.channels,
      this.moniker,
      this.other}) {
    assert(this.protocolVersion != null ||
        this.id != null ||
        this.listenAddress != null ||
        this.network != null ||
        this.version != null ||
        this.channels != null ||
        this.moniker != null ||
        this.other != null);
  }

  factory NodeInfo.fromJson(Map<String, dynamic> json) =>
      _$NodeInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NodeInfoToJson(this);
}
