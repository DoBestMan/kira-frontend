import 'package:json_annotation/json_annotation.dart';

part 'balance_model.g.dart';

@JsonSerializable()
class Pagination {
  String nextKey;
  int total;

  Pagination({this.nextKey, this.total}) {
    assert(this.nextKey != null || this.total != null);
  }

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BalanceModel {
  int balances;
  Pagination pagination;

  BalanceModel({this.balances, this.pagination}) {
    assert(this.balances != null || this.pagination != null);
  }

  factory BalanceModel.fromJson(Map<String, dynamic> json) =>
      _$BalanceModelFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceModelToJson(this);
}
