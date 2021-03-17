import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kira_auth/utils/colors.dart';

enum VoteType { UNSPECIFIED, YES, ABSTAIN, NO, NO_WITH_VETO }

enum ProposalType {
  MSG_VOTE, REGULAR, ASSIGN_PERMISSION, SET_NETWORK_PROPERTY, UPSERT_DATA_REGISTRY,
  SET_POOR_NETWORK_MESSAGES, UNJAIL_VALIDATOR, UPSERT_TOKEN_ALIAS, UPSERT_TOKEN_RATES
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ProposalContent {
  final String type;
  List<String> messages;

  ProposalContent({ this.type = "", this.messages }) {
    assert(this.type != null);
  }

  ProposalType getType() {
    switch (type) {
      case "/kira.gov.MsgVote":
        return ProposalType.MSG_VOTE;
      case "/kira.gov.AssignPermissionProposal":
        return ProposalType.ASSIGN_PERMISSION;
      case "/kira.gov.SetNetworkPropertyProposal":
        return ProposalType.SET_NETWORK_PROPERTY;
      case "/kira.gov.UpsertDataRegistryProposal":
        return ProposalType.UPSERT_DATA_REGISTRY;
      case "/kira.gov.SetPoorNetworkMessagesProposal":
        return ProposalType.SET_POOR_NETWORK_MESSAGES;
      case "/kira.staking.ProposalUnjailValidator":
        return ProposalType.UNJAIL_VALIDATOR;
      case "/kira.gov.ProposalUpsertTokenAlias":
        return ProposalType.UPSERT_TOKEN_ALIAS;
      case "/kira.gov.ProposalUpsertTokenRates":
        return ProposalType.UPSERT_TOKEN_RATES;
      default:
        return ProposalType.REGULAR;
    }
  }

  static ProposalContent parse(dynamic item) {
    if (item == null) return null;
    var content = new ProposalContent(type: item['@type']);
    switch (content.getType()) {
      case ProposalType.SET_POOR_NETWORK_MESSAGES:
        var messages = (item['messages'] ?? []) as List<dynamic>;
        content.messages = messages.map((e) => e.toString()).toList();
        break;
      default:
        break;
    }
    return content;
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
  List<VoteType> voteOptions;

  String get getStatusString => result.replaceAll("VOTE_", "");

  Proposal({ this.proposalId = "", this.result = "", this.submitTime, this.enactmentEndTime, this.votingEndTime, this.content }) {
    this.voteOptions = [];
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
