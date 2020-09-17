import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionModel {
  String depositAmount;
  String timestamp;
  String hash;

  TransactionModel({
    this.depositAmount,
    this.timestamp,
    this.hash,
  }) {
    assert(this.depositAmount != null ||
        this.timestamp != null ||
        this.hash != null);
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}
