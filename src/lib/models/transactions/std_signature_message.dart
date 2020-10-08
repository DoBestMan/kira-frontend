import 'package:meta/meta.dart';

class StdSignatureMessage {
  final String accountNumber;
  final String chainId;
  final String sequence;
  final String memo;
  final Map<String, dynamic> fee;
  final List<Map<String, dynamic>> msgs;

  const StdSignatureMessage({
    @required this.chainId,
    @required this.accountNumber,
    @required this.sequence,
    @required this.memo,
    @required this.fee,
    @required this.msgs,
  })  : assert(chainId != null),
        assert(accountNumber != null),
        assert(sequence != null),
        assert(msgs != null);

  Map<String, dynamic> toJson() => {
        'chain_id': chainId,
        'account_number': accountNumber,
        'sequence': sequence,
        'fee': fee,
        'msgs': msgs,
        'memo': memo,
      };
}
