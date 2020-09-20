import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionModel {
  String coin;
  String status;
  String depositAmount;
  String timestamp;
  String hash;
  String address;

  TransactionModel(
      {this.coin,
      this.status,
      this.depositAmount,
      this.timestamp,
      this.hash,
      this.address}) {
    assert(this.coin != null ||
        this.status != null ||
        this.depositAmount != null ||
        this.timestamp != null ||
        this.hash != null ||
        this.address != null);
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}
