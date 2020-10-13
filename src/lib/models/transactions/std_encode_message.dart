import 'package:kira_auth/models/transactions/std_encode_tx.dart';
import 'package:meta/meta.dart';

part 'std_encode_message.g.dart';

class StdEncodeMessage {
  final String chainId;
  final String accountNumber;
  final String sequence;
  final StdEncodeTx tx;

  const StdEncodeMessage({
    @required this.chainId,
    @required this.accountNumber,
    @required this.sequence,
    @required this.tx,
  })  : assert(chainId != null),
        assert(accountNumber != null),
        assert(sequence != null),
        assert(tx != null);

  factory StdEncodeMessage.fromJson(Map<String, dynamic> json) {
    return _$StdEncodeMessageFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$StdEncodeMessageToJson(this);
  }
}
