import 'package:json_annotation/json_annotation.dart';

part 'method.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Method {
  final String description;
  final bool enabled;
  final double rateLimit;
  final double authRateLimit;

  Method({this.description, this.enabled, this.rateLimit, this.authRateLimit});

  factory Method.fromJson(Map<String, dynamic> json) => _$MethodFromJson(json);

  Map<String, dynamic> toJson() => _$MethodToJson(this);
}
