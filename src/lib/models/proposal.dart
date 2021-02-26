import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kira_auth/utils/colors.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProposalContent {
  final String type;
  final List<String> messages;

  ProposalContent({ this.type = "", this.messages = [] }) {
    assert(this.type != null);
  }

  static ProposalContent parse(dynamic item) {
    if (item == null) return null;
    return ProposalContent(type: item['@type'], messages: item['messages'] ?? []);
  }
}

enum ProposalStatus { PASSED, FAILED, ENACTED }

@JsonSerializable(fieldRename: FieldRename.snake)
class Proposal {
  final String proposalId;
  final DateTime submitTime;
  final DateTime enactmentEndTime;
  final DateTime votingEndTime;
  final ProposalContent content;

  Proposal({ this.proposalId = "", this.submitTime, this.enactmentEndTime, this.votingEndTime, this.content }) {
    assert(this.proposalId != null);
  }

  ProposalStatus getStatus() {
    switch ("") {
      case "ACTIVE":
        return ProposalStatus.PASSED;
      case "ENACTED":
        return ProposalStatus.ENACTED;
      default:
        return ProposalStatus.FAILED;
    }
  }

  Color getStatusColor() {
    switch (getStatus()) {
      case ProposalStatus.PASSED:
        return KiraColors.green3;
      case ProposalStatus.ENACTED:
        return KiraColors.orange3;
      default:
        return KiraColors.danger;
    }
  }
}
