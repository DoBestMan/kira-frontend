import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'token.g.dart';

@JsonSerializable()
class Pagination {
  String nextKey;
  String total;

  Pagination({this.nextKey, this.total}) {
    assert(this.nextKey != null || this.total != null);
  }

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Token {
  String graphicalSymbol;
  String assetName;
  String ticker;
  double balance;
  String denomination;
  int decimals;
  Pagination pagination;

  Token(
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

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  factory Token.fromString(String data) {
    Map accMap = json.decode(data);
    return Token.fromJson(accMap);
  }
  Map<String, dynamic> toJson() => _$TokenToJson(this);

  String toString() => jsonEncode(toJson());
}
