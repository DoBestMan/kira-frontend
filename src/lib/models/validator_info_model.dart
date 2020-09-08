import 'package:json_annotation/json_annotation.dart';

part 'validator_info_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PubKey {
  final String type;
  final String value;

  PubKey({this.type, this.value}) {
    assert(this.type != null || this.value != null);
  }

  factory PubKey.fromJson(Map<String, dynamic> json) => _$PubKeyFromJson(json);

  Map<String, dynamic> toJson() => _$PubKeyToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ValidatorInfoModel {
  final String address;
  final PubKey pubKey;
  final String votingPower;

  ValidatorInfoModel({
    this.address,
    this.pubKey,
    this.votingPower,
  }) {
    assert(this.address != null ||
        this.pubKey != null ||
        this.votingPower != null);
  }

  factory ValidatorInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ValidatorInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ValidatorInfoModelToJson(this);
}