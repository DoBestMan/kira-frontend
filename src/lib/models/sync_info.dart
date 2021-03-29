import 'package:json_annotation/json_annotation.dart';

part 'sync_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SyncInfo {
  final String latestBlockHash;
  final String latestAppHash;
  final String latestBlockHeight;
  final String latestBlockTime;
  final String earlistBlockHash;
  final String earlistAppHash;
  final String earlistBlockHeight;
  final String earlistBlockTime;
  final bool catchingUp;

  SyncInfo(
      {this.latestBlockHash,
      this.latestAppHash,
      this.latestBlockHeight,
      this.latestBlockTime,
      this.earlistBlockHash,
      this.earlistAppHash,
      this.earlistBlockHeight,
      this.earlistBlockTime,
      this.catchingUp}) {
    assert(this.latestBlockHash != null ||
        this.latestAppHash != null ||
        this.latestBlockHeight != null ||
        this.latestBlockTime != null ||
        this.earlistBlockHash != null ||
        this.earlistAppHash != null ||
        this.earlistBlockHeight != null ||
        this.earlistBlockTime != null ||
        this.catchingUp != null);
  }

  factory SyncInfo.fromJson(Map<String, dynamic> json) => _$SyncInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SyncInfoToJson(this);
}
