import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/export.dart';

enum VoteOption { UNSPECIFIED, YES, ABSTAIN, NO, NO_WITH_VETO }

enum ProposalType {
  REGULAR, MSG_VOTE, ASSIGN_PERMISSION, SET_NETWORK_PROPERTY, UPSERT_DATA_REGISTRY,
  SET_POOR_NETWORK_MESSAGES, UNJAIL_VALIDATOR, UPSERT_TOKEN_ALIAS, UPSERT_TOKEN_RATES
}

enum ProposalStatus { UNKNOWN, PASSED, REJECTED, REJECTED_WITH_VETO, PENDING, QUORUM_NOT_REACHED }

@JsonSerializable(fieldRename: FieldRename.snake)
class ProposalContent {
  final String type;
  List<String> messages = [];
  String value = "";
  String address = "";
  int permission = -1;
  String get getPermissionName => Strings.permissionNames[permission];
  String get getAddress => Bech32Encoder.encode("kira", base64.decode(address));

  ProposalContent({ this.type = "" }) {
    assert(this.type != null);
  }

  ProposalType getType() {
    var index = Strings.proposalTypes.indexOf(type);
    return index < 0 ? ProposalType.REGULAR : ProposalType.values[index];
  }

  static ProposalContent parse(dynamic item) {
    if (item == null) return null;
    var content = new ProposalContent(type: item['@type']);
    switch (content.getType()) {
      case ProposalType.SET_POOR_NETWORK_MESSAGES:
        var messages = (item['messages'] ?? []) as List<dynamic>;
        content.messages = messages.map((e) => e.toString()).toList();
        break;
      case ProposalType.SET_NETWORK_PROPERTY:
        content.value = item['value'];
        break;
      case ProposalType.ASSIGN_PERMISSION:
        content.address = item['address'];
        content.permission = item['permission'];
        break;
      default:
        break;
    }
    return content;
  }

  String getDescription() {
    switch (getType()) {
      case ProposalType.SET_POOR_NETWORK_MESSAGES:
        return "Poor Network Messages: " + messages.join(", ");
      case ProposalType.SET_NETWORK_PROPERTY:
        return "Network Property Value: $value";
      case ProposalType.ASSIGN_PERMISSION:
        return permission < 0 ? "Undefined" : "Assign $getPermissionName Permission to Account $getAddress";
      default:
        return "Unknown";
    }
  }
}

class Voteability {
  List<VoteOption> voteOptions = [];
  List<String> whitelistPermissions = [];
  List<String> blacklistPermissions = [];

  Voteability({ this.voteOptions, this.whitelistPermissions, this.blacklistPermissions });
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Proposal {
  final String proposalId;
  final dynamic result;
  final DateTime submitTime;
  final DateTime enactmentEndTime;
  final DateTime votingEndTime;
  final ProposalContent content;
  Voteability voteability;
  String get getContent => content.getDescription();

  Proposal({ this.proposalId = "", this.result = "", this.submitTime, this.enactmentEndTime, this.votingEndTime, this.content }) {
    assert(this.proposalId != null, this.result != null);
  }

  bool get isVoteable => availableVoteOptions().isNotEmpty && votingEndTime.isAfter(DateTime.now());

  List<VoteOption> availableVoteOptions() {
    var isVoteable = false;
    switch (content.getType()) {
      case ProposalType.SET_POOR_NETWORK_MESSAGES:
        isVoteable = voteability.whitelistPermissions.contains(Strings.permissionValues[19])
          && !voteability.blacklistPermissions.contains(Strings.permissionValues[19]);
        break;
      case ProposalType.SET_NETWORK_PROPERTY:
        isVoteable = voteability.whitelistPermissions.contains(Strings.permissionValues[13])
          && !voteability.blacklistPermissions.contains(Strings.permissionValues[13]);
        break;
      case ProposalType.ASSIGN_PERMISSION:
        isVoteable = voteability.whitelistPermissions.contains(Strings.permissionValues[5])
          && !voteability.blacklistPermissions.contains(Strings.permissionValues[5]);
        break;
      default:
        break;
    }
    return isVoteable ? voteability.voteOptions : [];
  }

  ProposalStatus getStatus() {
    if (result is String) {
      return ProposalStatus.values[Strings.voteResults.indexOf(result)];
    } else {
      return ProposalStatus.values[result];
    }
  }

  String getStatusString() {
    switch (getStatus()) {
      case ProposalStatus.PASSED:
        return "Passed";
      case ProposalStatus.REJECTED:
        return "Rejected";
      case ProposalStatus.REJECTED_WITH_VETO:
        return "Rejected with Veto";
      case ProposalStatus.PENDING:
        return "Pending";
      case ProposalStatus.QUORUM_NOT_REACHED:
        return "Quorum not reached";
      default:
        return "Unknown";
    }
  }

  Color getStatusColor() {
    switch (getStatus()) {
      case ProposalStatus.PASSED:
        return KiraColors.green3;
      case ProposalStatus.REJECTED:
      case ProposalStatus.REJECTED_WITH_VETO:
        return KiraColors.orange3;
      case ProposalStatus.QUORUM_NOT_REACHED:
        return KiraColors.danger;
      case ProposalStatus.PENDING:
        return KiraColors.purple1;
      default:
        return KiraColors.kGrayColor;
    }
  }
}
