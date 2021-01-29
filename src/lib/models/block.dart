import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kira_auth/utils/colors.dart';

// part 'block.g.dart';

enum BlockStatus { UNDEFINED, ACTIVE, INACTIVE, PAUSED }

@JsonSerializable(fieldRename: FieldRename.snake)
class Block {
  final String address;
  final String valkey;
  final String pubkey;
  final String moniker;
  final String website;
  final String social;
  final String identity;
  final double commission;
  final String status;
  final int rank;
  final int streak;
  final int mischance;
  bool isFavorite;

  Block({ this.address = "", this.valkey = "", this.pubkey = "", this.moniker = "", this.website = "", this.social = "",
    this.identity = "", this.commission = 0, this.status = "", this.rank = 0, this.streak = 0, this.mischance = 0, this.isFavorite = false }) {
    assert(this.address != null || this.valkey != null || this.pubkey != null || this.moniker != null || this.status != null);
  }

  BlockStatus getStatus() {
    switch (status) {
      case "ACTIVE":
        return BlockStatus.ACTIVE;
      case "INACTIVE":
        return BlockStatus.INACTIVE;
      case "PAUSED":
        return BlockStatus.PAUSED;
      default:
        return BlockStatus.UNDEFINED;
    }
  }

  Color getStatusColor() {
    switch (getStatus()) {
      case BlockStatus.ACTIVE:
        return KiraColors.green3;
      case BlockStatus.INACTIVE:
        return KiraColors.kGrayColor;
      case BlockStatus.PAUSED:
        return KiraColors.orange3;
      default:
        return KiraColors.danger;
    }
  }

  Color getCommissionColor() {
    if (commission >= 0.75)
      return KiraColors.green3;
    if (commission >= 0.5)
      return KiraColors.orange3;
    if (commission >= 0.25)
        return KiraColors.kGrayColor;
    return KiraColors.danger;
  }

  String checkUnknownWith(String field) {
    var value = field == "website" ? website : field == "social" ? social : field == "identity" ? identity : "";
    return value.isEmpty ? "Unknown" : value;
  }

  // factory Block.fromJson(Map<String, dynamic> json) =>
  //     _$BlockFromJson(json);
  //
  // Map<String, dynamic> toJson() => _$BlockToJson(this);
}

