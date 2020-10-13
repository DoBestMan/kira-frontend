import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:kira_auth/models/transactions/export.dart';

class StdEncodeTx {
  final List<MsgSend> msg;
  final StdFee fee;
  final List<String> signatures;
  final String memo;

  StdEncodeTx({
    @required this.msg,
    @required this.fee,
    @required this.signatures,
    @required this.memo,
  })  : assert(msg != null),
        assert(fee != null),
        assert(signatures == null || signatures.isNotEmpty);

  Map<String, dynamic> toJson() => {
        'msg': this.msg.map((e) => e?.toJsonForEncode())?.toList(),
        'fee': this.fee.toJson(),
        'signatures': this.signatures != null ? this.signatures : [],
        'memo': this.memo,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
