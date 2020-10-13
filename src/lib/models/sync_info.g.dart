// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncInfo _$SyncInfoFromJson(Map<String, dynamic> json) {
  return SyncInfo(
    latestBlockHash: json['latest_block_hash'] as String,
    latestAppHash: json['latest_app_hash'] as String,
    latestBlockHeight: json['latest_block_height'] as String,
    latestBlockTime: json['latest_block_time'] as String,
    earlistBlockHash: json['earlist_block_hash'] as String,
    earlistAppHash: json['earlist_app_hash'] as String,
    earlistBlockHeight: json['earlist_block_height'] as String,
    earlistBlockTime: json['earlist_block_time'] as String,
    catchingUp: json['catching_up'] as bool,
  );
}

Map<String, dynamic> _$SyncInfoToJson(SyncInfo instance) => <String, dynamic>{
      'latest_block_hash': instance.latestBlockHash,
      'latest_app_hash': instance.latestAppHash,
      'latest_block_height': instance.latestBlockHeight,
      'latest_block_time': instance.latestBlockTime,
      'earlist_block_hash': instance.earlistBlockHash,
      'earlist_app_hash': instance.earlistAppHash,
      'earlist_block_height': instance.earlistBlockHeight,
      'earlist_block_time': instance.earlistBlockTime,
      'catching_up': instance.catchingUp,
    };
