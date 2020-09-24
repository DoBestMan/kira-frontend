import 'package:json_annotation/json_annotation.dart';

part 'method_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MethodModel {
  final String description;
  final bool enabled;
  final double rateLimit;
  final double authRateLimit;

  MethodModel(
      {this.description, this.enabled, this.rateLimit, this.authRateLimit});

  factory MethodModel.fromJson(Map<String, dynamic> json) =>
      _$MethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$MethodModelToJson(this);
}
