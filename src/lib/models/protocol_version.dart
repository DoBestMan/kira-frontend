import 'package:json_annotation/json_annotation.dart';

part 'protocol_version.g.dart';

@JsonSerializable()
class ProtocolVersion {
  final String p2p;
  final String block;
  final String app;

  ProtocolVersion({
    this.p2p,
    this.block,
    this.app,
  }) {
    assert(this.p2p != null || this.block != null || this.app != null);
  }

  factory ProtocolVersion.fromJson(Map<String, dynamic> json) => _$ProtocolVersionFromJson(json);

  Map<String, dynamic> toJson() => _$ProtocolVersionToJson(this);
}
