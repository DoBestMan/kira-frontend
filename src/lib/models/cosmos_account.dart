import 'package:meta/meta.dart';
import 'package:kira_auth/models/transactions/export.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cosmos_account.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class CosmosAccount extends Equatable {
  @JsonKey(name: 'address', defaultValue: '')
  final String address;

  @JsonKey(name: 'account_number', defaultValue: '')
  final String accountNumber;

  @JsonKey(name: 'sequence', defaultValue: '')
  final String sequence;

  @JsonKey(name: 'coins', defaultValue: [])
  final List<StdCoin> coins;

  const CosmosAccount({
    @required this.address,
    @required this.accountNumber,
    @required this.sequence,
    @required this.coins,
  });

  factory CosmosAccount.offline(String address) {
    return CosmosAccount(
      address: address,
      accountNumber: '',
      sequence: '',
      coins: [],
    );
  }

  factory CosmosAccount.fromJson(Map<String, dynamic> json) {
    return _$CosmosAccountFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$CosmosAccountToJson(this);
  }

  CosmosAccount copyWith({
    String address,
    String accountNumber,
    String sequence,
    List<StdCoin> coins,
  }) {
    return CosmosAccount(
      address: address ?? this.address,
      accountNumber: accountNumber ?? this.accountNumber,
      sequence: sequence ?? this.sequence,
      coins: coins ?? this.coins,
    );
  }

  @override
  List<Object> get props {
    return [address, accountNumber, sequence, coins];
  }

  @override
  String toString() {
    return 'CosmosAccount { '
        'address: $address, '
        'accountNumber: $accountNumber, '
        'sequence: $sequence, '
        'coins: $coins '
        '}';
  }
}
