import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kira_auth/utils/colors.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProposalContent {
  final String type;
  final List<String> messages;

  ProposalContent({ this.type = "", this.messages }) {
    assert(this.type != null);
  }

  static ProposalContent parse(dynamic item) {
    if (item == null) return null;
    var messages = (item['messages'] ?? []) as List<dynamic>;
    return ProposalContent(type: item['@type'], messages: messages.map((e) => e.toString()).toList());
  }
}

enum ProposalStatus { PENDING, PASSED, FAILED, ENACTED }

@JsonSerializable(fieldRename: FieldRename.snake)
class Proposal {
  final String proposalId;
  final String result;
  final DateTime submitTime;
  final DateTime enactmentEndTime;
  final DateTime votingEndTime;
  final ProposalContent content;

  String get getStatusString => result.replaceAll("VOTE_", "");

  Proposal({ this.proposalId = "", this.result = "", this.submitTime, this.enactmentEndTime, this.votingEndTime, this.content }) {
    assert(this.proposalId != null, this.result != null);
  }

  ProposalStatus getStatus() {
    switch (result) {
      case "VOTE_PENDING":
        return ProposalStatus.PENDING;
      case "VOTE_PASSED":
        return ProposalStatus.PASSED;
      case "VOTE_ENACTED":
        return ProposalStatus.ENACTED;
      default:
        return ProposalStatus.FAILED;
    }
  }

  Color getStatusColor() {
    switch (getStatus()) {
      case ProposalStatus.PENDING:
        return KiraColors.kGrayColor;
      case ProposalStatus.PASSED:
        return KiraColors.green3;
      case ProposalStatus.ENACTED:
        return KiraColors.orange3;
      default:
        return KiraColors.danger;
    }
  }
}
