import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:kira_auth/models/transactions/export.dart';

class VoteTx {
  final VoteMsg voteMsg;
  final AuthInfo authInfo;
  final List<String> signatures;

  VoteTx({
    @required this.voteMsg,
    @required this.authInfo,
    @required this.signatures,
  })  : assert(voteMsg != null),
        assert(authInfo != null),
        assert(signatures == null || signatures.isNotEmpty);

  Map<String, dynamic> toJson() => {
    'body': this.voteMsg.toJson(),
    'auth_info': this.authInfo.toJson(),
    'signatures': this.signatures != null ? this.signatures : [],
  };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
