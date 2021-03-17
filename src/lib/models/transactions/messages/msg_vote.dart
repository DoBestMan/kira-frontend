import 'package:json_annotation/json_annotation.dart';
import 'package:kira_auth/models/proposal.dart';
import 'package:meta/meta.dart';
import 'package:kira_auth/models/transactions/export.dart';

part 'msg_vote.g.dart';

/// [MsgVote] represents the message that should be
/// used when sending tokens from one user to another one.
/// It requires to specify the address from which to send the tokens,
/// the one that should receive the tokens and the amount of tokens
/// to send.
@JsonSerializable(explicitToJson: true)
class MsgVote {
  /// Bech32 address of the voter.
  @JsonKey(name: 'voter')
  final String voter;

  /// Proposal ID to vote on.
  @JsonKey(name: 'proposal_id')
  final String proposalId;

  /// Vote option.
  @JsonKey(name: 'option')
  final VoteType option;

  /// Public constructor.
  MsgVote({
    @required this.voter,
    @required this.proposalId,
    @required this.option,
  });

  factory MsgVote.fromJson(Map<String, dynamic> json) {
    return _$MsgVoteFromJson(json);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> response = {'@type': "/kira.gov.MsgVote"};
    response.addAll(_$MsgVoteToJson(this));
    return response;
  }

  Map<String, dynamic> toEncodeJson() {
    Map<String, dynamic> response = {
      'type': "cosmos-sdk/MsgVote",
      'value': _$MsgVoteToJson(this)
    };
    return response;
  }

  Exception validate() {
    if (proposalId.isEmpty) {
      return Exception('proposal id must be set');
    }

    if (voter.isEmpty) {
      return Exception('user session is invalid');
    }

    return null;
  }
}
