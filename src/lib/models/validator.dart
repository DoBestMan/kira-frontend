import 'package:json_annotation/json_annotation.dart';

// part 'validator.g.dart';

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

  Validator({ this.address, this.valkey, this.pubkey, this.moniker, this.website, this.social,
    this.identity, this.commission, this.status, this.rank, this.streak, this.mischance }) {
    assert(this.address != null || this.valkey != null || this.pubkey != null ||
        this.address != null || this.pubkey != null || this.rank != null ||
        this.address != null || this.pubkey != null || this.rank != null);
  }

  // factory Validator.fromJson(Map<String, dynamic> json) =>
  //     _$ValidatorFromJson(json);
  //
  // Map<String, dynamic> toJson() => _$ValidatorToJson(this);
}

