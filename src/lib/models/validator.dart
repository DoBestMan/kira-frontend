import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kira_auth/utils/colors.dart';

// part 'validator.g.dart';

enum ValidatorStatus { UNDEFINED, ACTIVE, INACTIVE, PAUSED }

@JsonSerializable(fieldRename: FieldRename.snake)
class Validator {
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
  bool isLiked;

  Validator({ this.address = "", this.valkey = "", this.pubkey = "", this.moniker = "", this.website = "", this.social = "",
    this.identity = "", this.commission = 0, this.status = "", this.rank = 0, this.streak = 0, this.mischance = 0, this.isLiked = false }) {
    assert(this.address != null || this.valkey != null || this.pubkey != null || this.moniker != null || this.status != null);
  }

  ValidatorStatus getStatus() {
    switch (status) {
      case "ACTIVE":
        return ValidatorStatus.ACTIVE;
      case "INACTIVE":
        return ValidatorStatus.INACTIVE;
      case "PAUSED":
        return ValidatorStatus.PAUSED;
      default:
        return ValidatorStatus.UNDEFINED;
    }
  }

  Color getColor() {
    switch (getStatus()) {
      case ValidatorStatus.ACTIVE:
        return KiraColors.green3;
      case ValidatorStatus.INACTIVE:
        return KiraColors.kGrayColor;
      case ValidatorStatus.PAUSED:
        return KiraColors.orange3;
      default:
        return KiraColors.danger;
    }
    return KiraColors.black;
  }

  // factory Validator.fromJson(Map<String, dynamic> json) =>
  //     _$ValidatorFromJson(json);
  //
  // Map<String, dynamic> toJson() => _$ValidatorToJson(this);
}

