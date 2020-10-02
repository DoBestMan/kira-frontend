import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cosmos_account.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class CosmosAccount extends Equatable {
  @JsonKey(name: '@type', defaultValue: '')
  final String type;

  @JsonKey(name: 'account_number', defaultValue: '')
  final String accountNumber;

  @JsonKey(name: 'address', defaultValue: '')
  final String address;

  @JsonKey(name: 'sequence', defaultValue: '')
  final String sequence;

  @JsonKey(name: 'pubKey', defaultValue: '')
  final String pubKey;

  const CosmosAccount({
    @required this.type,
    @required this.address,
    @required this.accountNumber,
    @required this.sequence,
    @required this.pubKey,
  });

  factory CosmosAccount.offline(String address) {
    return CosmosAccount(
        type: '',
        address: address,
        accountNumber: '',
        sequence: '',
        pubKey: '');
  }

  factory CosmosAccount.fromJson(Map<String, dynamic> json) {
    return _$CosmosAccountFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$CosmosAccountToJson(this);
  }

  CosmosAccount copyWith(
      {String type,
      String address,
      String accountNumber,
      String sequence,
      String pubKey}) {
    return CosmosAccount(
      type: type ?? this.type,
      address: address ?? this.address,
      accountNumber: accountNumber ?? this.accountNumber,
      sequence: sequence ?? this.sequence,
      pubKey: pubKey ?? this.pubKey,
    );
  }

  @override
  List<Object> get props {
    return [type, address, accountNumber, sequence, pubKey];
  }

  @override
  String toString() {
    return 'CosmosAccount { '
        'type: $type, '
        'address: $address, '
        'accountNumber: $accountNumber, '
        'sequence: $sequence, '
        'pubKey: $pubKey '
        '}';
  }
}
