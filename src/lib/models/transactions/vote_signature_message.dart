import 'package:meta/meta.dart';
import 'package:kira_auth/models/transactions/export.dart';

part 'vote_signature_message.g.dart';

class VoteSignatureMessage {
  final String accountNumber;
  final String chainId;
  final String sequence;
  final String memo;
  final StdFee fee;
  final List<MsgVote> msgs;

  const VoteSignatureMessage({
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

  factory VoteSignatureMessage.fromJson(Map<String, dynamic> json) {
    return _$VoteSignatureMessageFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$VoteSignatureMessageToJson(this);
  }
}
