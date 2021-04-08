import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/export.dart';

enum VoteOption { UNSPECIFIED, YES, ABSTAIN, NO, NO_WITH_VETO }

enum ProposalType {
  UNKNOWN, ASSIGN_PERMISSION, SET_POOR_NETWORK_MESSAGES, SET_NETWORK_PROPERTY, UPSERT_DATA_REGISTRY,
  CREATE_ROLE, UNJAIL_VALIDATOR, UPSERT_TOKEN_ALIAS, UPSERT_TOKEN_RATES, UPDATE_TOKENS_BLACK_WHITE
}

enum ProposalStatus { UNKNOWN, PASSED, REJECTED, REJECTED_WITH_VETO, PENDING, QUORUM_NOT_REACHED, ENACTMENT }

enum VotingStatus { Voting, Enacted, Expired }

@JsonSerializable(fieldRename: FieldRename.snake)
class ProposalContent {
  final String type;
  String raw;

  /// Poor Network Proposal
  List<String> messages = [];

  /// Network Property
  String value = "";
  String networkProperty = "";

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
  List<String> whitelist;
  List<String> blacklist;

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

  /// Update Tokens Black/White
  bool isAdd;
  bool isBlacklist;
  List<String> tokens = [];

  String get getPermissionName => Strings.permissionNames[permission];
  String get getAddress => Bech32Encoder.encode("kira", base64.decode(address));
  String get getRawDescription => raw;

  ProposalContent({ this.type = "" }) {
    assert(this.type != null);
  }

  ProposalType getType() => ProposalType.values[Strings.proposalTypes.indexOf(type) + 1];

  String getName() => Strings.proposalNames[Strings.proposalTypes.indexOf(type) + 1];

  static ProposalContent parse(dynamic item) {
    if (item == null) return null;
    var content = new ProposalContent(type: item['@type']);
    content.raw = jsonEncode(item);
    switch (content.getType()) {
      case ProposalType.ASSIGN_PERMISSION:
        content.address = item['address'];
        content.permission = item['permission'];
        break;
      case ProposalType.SET_POOR_NETWORK_MESSAGES:
        var messages = (item['messages'] ?? []) as List<dynamic>;
        content.messages = messages.map((e) => e.toString()).toList();
        break;
      case ProposalType.SET_NETWORK_PROPERTY:
        content.value = item['value'];
        content.networkProperty = item['network_property'];
        break;
      case ProposalType.UPSERT_DATA_REGISTRY:
        content.encoding = item['encoding'];
        content.hash = item['hash'];
        content.key = item['key'];
        content.reference = item['reference'];
        try { content.size = int.parse(item['size']); } catch (e) { content.size = 0; }
        break;
      case ProposalType.CREATE_ROLE:
        content.role = item['role'];
        var whitelist = (item['whitelisted_permissions'] ?? []) as List<dynamic>;
        var blacklist = (item['blacklisted_permissions'] ?? []) as List<dynamic>;
        content.whitelist = whitelist.map((e) => e.toString()).toList();
        content.blacklist = blacklist.map((e) => e.toString()).toList();
        break;
      case ProposalType.UNJAIL_VALIDATOR:
        content.hash = item['hash'];
        content.reference = item['reference'];
        break;
      case ProposalType.UPSERT_TOKEN_ALIAS:
        content.decimals = item['decimals'];
        var denoms = (item['denoms'] ?? []) as List<dynamic>;
        content.denoms = denoms.map((e) => e.toString()).toList();
        content.icon = item['icon'];
        content.name = item['name'];
        content.symbol = item['symbol'];
        break;
      case ProposalType.UPSERT_TOKEN_RATES:
        content.denom = item['denom'];
        content.feePayments = item['fee_payments'];
        try { content.rate = double.parse(item['rate']); } catch (_) { content.rate = 0.0; }
        break;
      case ProposalType.UPDATE_TOKENS_BLACK_WHITE:
        var tokens = (item['tokens'] ?? []) as List<dynamic>;
        content.tokens = tokens.map((e) => e.toString()).toList();
        content.isAdd = item['is_add'];
        content.isBlacklist = item['is_blacklist'];
        break;
      default:
        break;
    }
    return content;
  }
}

class Voteability {
  List<VoteOption> voteOptions = [];
  List<String> whitelistPermissions = [];
  List<String> blacklistPermissions = [];
  int count;

  Voteability({ this.voteOptions, this.whitelistPermissions, this.blacklistPermissions, this.count = 0 });
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Proposal {
  final String proposalId;
  final dynamic result;
  final String description;
  final DateTime submitTime;
  final DateTime enactmentEndTime;
  final DateTime votingEndTime;
  final ProposalContent content;
  Voteability voteability;
  Map<String, double> voteResults;
  String get getContent => content.raw;

  Proposal({ this.proposalId = "", this.description = "", this.result = "", this.submitTime, this.enactmentEndTime, this.votingEndTime, this.content }) {
    assert(this.proposalId != null, this.result != null);
  }

  bool get isVoteable => availableVoteOptions().isNotEmpty && votingEndTime.isAfter(DateTime.now());

  List<VoteOption> availableVoteOptions() {
    var isVoteable = false;
    switch (content.getType()) {
      case ProposalType.SET_POOR_NETWORK_MESSAGES:
        isVoteable = voteability.whitelistPermissions.contains(Strings.permissionValues[17])
          && !voteability.blacklistPermissions.contains(Strings.permissionValues[17]);
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
      return ProposalStatus.values[Strings.voteResults.indexOf(result) + 1];
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
        return "No Quorum";
      case ProposalStatus.ENACTMENT:
        return "Enactment";
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
        return KiraColors.danger;
      case ProposalStatus.QUORUM_NOT_REACHED:
        return KiraColors.kYellowColor;
      case ProposalStatus.PENDING:
        return KiraColors.white;
      default:
        return KiraColors.kGrayColor;
    }
  }

  VotingStatus getVotingStatus() {
    final now = DateTime.now();
    if (now.isBefore(votingEndTime))
      return VotingStatus.Voting;
    if (now.isBefore(enactmentEndTime))
      return VotingStatus.Enacted;
    return VotingStatus.Expired;
  }

  int get getTimer => getVotingStatus() == VotingStatus.Voting ? votingEndTime.millisecondsSinceEpoch : enactmentEndTime.millisecondsSinceEpoch;
  format(Duration d) => d.toString().split('.').first.padLeft(8, '0');

  Color getTimeColor() {
    switch (getVotingStatus()) {
      case VotingStatus.Voting:
        return KiraColors.green3;
      case VotingStatus.Enacted:
        return KiraColors.orange3;
      default:
        return KiraColors.kGrayColor;
    }
  }
}
