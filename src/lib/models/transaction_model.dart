import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionModel {
  String token;
  String hash;
  String status;
  String depositAmount;
  String timestamp;
  String from;
  String to;
  String fee;

  TransactionModel(
      {this.token,
      this.hash,
      this.status,
      this.depositAmount,
      this.timestamp,
      this.from,
      this.to,
      this.fee});

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}
