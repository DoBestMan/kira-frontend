import 'package:json_annotation/json_annotation.dart';

part 'protocol_version_model.g.dart';

@JsonSerializable()
class ProtocolVersionModel {
  final String p2p;
  final String block;
  final String app;

  ProtocolVersionModel({
    this.p2p,
    this.block,
    this.app,
  }) {
    assert(this.p2p != null || this.block != null || this.app != null);
  }

  factory ProtocolVersionModel.fromJson(Map<String, dynamic> json) =>
      _$ProtocolVersionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProtocolVersionModelToJson(this);
}
