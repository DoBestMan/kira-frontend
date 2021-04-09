import 'package:json_annotation/json_annotation.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/utils/export.dart';

enum TxType {
  UNKNOWN, SEND, MULTISEND, PROPOSAL_ASSIGN_PERMISSION, PROPOSAL_SET_NETWORK_PROPERTY,
  PROPOSAL_UPSERT_DATA_REGISTRY, PROPOSAL_UPSERT_TOKEN_ALIAS, VOTE_PROPOSAL,
  WHITELIST_PERMISSIONS, BLACKLIST_PERMISSIONS, CLAIM_COUNCILOR,
  SET_NETWORK_PROPERTIES, SET_EXECUTION_FEE, CREATE_ROLE, ASSIGN_ROLE, REMOVE_ROLE,
  WHITELIST_ROLE_PERMISSION, BLACKLIST_ROLE_PERMISSION,
  REMOVE_WHITELIST_ROLE_PERMISSION, REMOVE_BLACKLIST_ROLE_PERMISSION,
  CLAIM_VALIDATOR, UPSERT_TOKEN_ALIAS, UPSERT_TOKEN_RATE
}

class CopyableText {
  String value;
  String toast;

  bool get isCopyable => toast.isNotEmpty;

  CopyableText({ this.value, this.toast = "" });
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TxMsg {
  TxType type;
  Map<String, dynamic> data;

  String get getType => Strings.messageNames[TxType.values.indexOf(type)];

  TxMsg({this.type, this.data });

  static TxMsg fromJson(Map<String, dynamic> json) {
    return TxMsg(
      type: TxType.values[Strings.messageTypes.indexOf(json['type'] as String) + 1],
      data: json['data'] as Map<String, dynamic>
    );
  }

  Map<String, CopyableText> getDetails() {
    switch (type) {
      case TxType.SEND:
        var send = TxSend.fromJson(data);
        return {
          "From": CopyableText(value: send.from, toast: Strings.senderAddressCopied),
          "To": CopyableText(value: send.to, toast: Strings.recipientAddressCopied),
          "Amount": CopyableText(value: send.amounts[0].amount + " " + send.amounts[0].denom)
        };
      case TxType.VOTE_PROPOSAL:
        var vote = TxVote.fromJson(data);
        return {
          "Voter": CopyableText(value: vote.voter, toast: Strings.voterCopied),
          "Vote Option": CopyableText(value: Strings.voteOptions[vote.option - 1]),
          "Proposal Id": CopyableText(value: vote.proposalId),
        };
      default:
        return {" ": CopyableText(value: "Coming Soon")};
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TxSend {
  String from;
  String to;
  List<StdCoin> amounts;

  TxSend({this.from, this.to, this.amounts});

  static TxSend fromJson(Map<String, dynamic> json) {
    return TxSend(
      from: json['from'],
      to: json['to'],
      amounts: (json['amounts'] as List<dynamic>).map((e) => StdCoin.fromJson(e)).toList(),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TxVote {
  final String voter;
  final String proposalId;
  final int option;

  TxVote({ this.voter = "Unknown", this.proposalId = "0", this.option = 0}) {
    assert(this.voter != null, this.proposalId != null);
  }

  static TxVote fromJson(Map<String, dynamic> json) {
    return TxVote(
        voter: json['voter'].toString(),
        proposalId: json['proposal_id'].toString(),
        option: json['option']
    );
  }
}
