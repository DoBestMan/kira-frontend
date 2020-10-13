import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Transaction {
  String token;
  String hash;
  String status;
  String depositAmount;
  String timestamp;
  String from;
  String to;
  String fee;

  Transaction(
      {this.token,
      this.hash,
      this.status,
      this.depositAmount,
      this.timestamp,
      this.from,
      this.to,
      this.fee});

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
