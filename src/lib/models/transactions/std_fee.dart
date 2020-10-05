import 'package:meta/meta.dart';
import 'package:kira_auth/models/transactions/std_coin.dart';

class StdFee {
  final String gas;
  final List<StdCoin> amount;

  const StdFee({
    @required this.amount,
    @required this.gas,
  }) : assert(gas != null);

  Map<String, dynamic> toJson() => {
        'amount': this.amount.map((coin) => coin.toJson()).toList(),
        'gas_limit': this.gas,
      };

  factory StdFee.fromJson(Map<String, dynamic> json) {
    return StdFee(
      gas: json['gas'],
      amount: ((json['amount']) as List)
          ?.map((e) => e == null ? null : StdCoin.fromJson(e))
          ?.toList(),
    );
  }
}
