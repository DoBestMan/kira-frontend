import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/export.dart';

enum VoteOption { UNSPECIFIED, YES, ABSTAIN, NO, NO_WITH_VETO }

enum ProposalType {
  UNKNOWN, ASSIGN_PERMISSION, SET_NETWORK_PROPERTY, UPSERT_DATA_REGISTRY, SET_POOR_NETWORK_MESSAGES,
  CREATE_ROLE, UNJAIL_VALIDATOR, UPSERT_TOKEN_ALIAS, UPSERT_TOKEN_RATES
}

enum ProposalStatus { UNKNOWN, PASSED, REJECTED, REJECTED_WITH_VETO, PENDING, QUORUM_NOT_REACHED }

@JsonSerializable(fieldRename: FieldRename.snake)
class ProposalContent {
  final String type;

  /// Poor Network Proposal
  List<String> messages = [];

  /// Network Property
  String value = "";

  /// Assign Permission
  String address = "";
  int permission = -1;

  /// Upsert Data Registry
  String encoding;
  String key;
  String hash;
  String reference;
  int size;

  /// Create Role
  int role;
  List<int> whitelist;
  List<int> blacklist;

  /// Upsert Token Rate
  String denom;
  bool feePayments;
  double rate;

  /// Upsert Token Alias
  int decimals;
  List<String> denoms = [];
  String icon;
  String name;
  String symbol;

  String get getPermissionName => Strings.permissionNames[permission];
  String get getAddress => Bech32Encoder.encode("kira", base64.decode(address));

  ProposalContent({ this.type = "" }) {
    assert(this.type != null);
  }

  ProposalType getType() => ProposalType.values[Strings.proposalTypes.indexOf(type) + 1];

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
      case ProposalType.CREATE_ROLE:
        try { content.role = int.parse(item['role']); } catch (e) { content.role = 0; }
        content.whitelist = (item['whitelist'] ?? []) as List<dynamic>;
        content.blacklist = (item['blacklist'] ?? []) as List<dynamic>;
        break;
      case ProposalType.UPSERT_DATA_REGISTRY:
        content.encoding = item['encoding'];
        content.hash = item['hash'];
        content.key = item['key'];
        content.reference = item['reference'];
        try { content.size = int.parse(item['size']); } catch (e) { content.size = 0; }
        break;
      case ProposalType.UPSERT_TOKEN_RATES:
        content.denom = item['denom'];
        content.feePayments = (item['fee_payments'] as String).toLowerCase() == "true";
        content.rate = double.parse(item['rate']);
        break;
      case ProposalType.UPSERT_TOKEN_ALIAS:
        try { content.decimals = int.parse(item['decimals']); } catch (e) { content.decimals = 0; }
        content.denoms = (item['denoms'] ?? []) as List<dynamic>;
        content.icon = item['icon'];
        content.name = item['name'];
        content.symbol = item['symbol'];
        break;
      case ProposalType.UPSERT_TOKEN_ALIAS:
        content.hash = item['hash'];
        content.reference = item['reference'];
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
      case ProposalType.UPSERT_DATA_REGISTRY:
        return "Upsert Data Registry - Encoding: $encoding, Hash: $hash, Key: $key, Reference: $reference, Size: $size";
      case ProposalType.CREATE_ROLE:
        return "Create a new role: $role";
      case ProposalType.UNJAIL_VALIDATOR:
        return "Unjail validator - Hash: $hash, Reference: $reference";
        break;
      case ProposalType.UPSERT_TOKEN_RATES:
        return "Upsert Token Rate - Denom: $denom, Rate: ${rate.toStringAsFixed(2)}, Fee payments: ${feePayments ? "Yes" : "No"}";
      case ProposalType.UPSERT_TOKEN_ALIAS:
        return "Upsert Token Alias - Denoms: ${denoms.join(", ")}, Decimals: $decimals, Icon: $icon, Name: $name, Symbol: $symbol";
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
