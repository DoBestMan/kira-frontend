import 'package:json_annotation/json_annotation.dart';

part 'token_model.g.dart';

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
class TokenModel {
  String graphicalSymbol;
  String assetName;
  String ticker;
  double balance;
  String denomination;
  int decimals;
  Pagination pagination;

  TokenModel(
      {this.graphicalSymbol,
      this.assetName,
      this.ticker,
      this.balance,
      this.denomination,
      this.decimals,
      this.pagination}) {
    assert(this.graphicalSymbol != null ||
        this.assetName != null ||
        this.ticker != null ||
        this.balance != null ||
        this.denomination != null ||
        this.decimals != null ||
        this.pagination != null);
  }

  factory TokenModel.fromJson(Map<String, dynamic> json) =>
      _$TokenModelFromJson(json);
  Map<String, dynamic> toJson() => _$TokenModelToJson(this);
}
