// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'msg_vote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MsgVote _$MsgVoteFromJson(Map<String, dynamic> json) {
  return MsgVote(
    proposalId: json['proposal_id'] as String,
    voter: json['voter'] as String,
    option: json['option'],
  );
}

Map<String, dynamic> _$MsgVoteToJson(MsgVote instance) => <String, dynamic>{
      'proposal_id': instance.proposalId,
      'voter': instance.voter,
      'option': instance.option,
    };
