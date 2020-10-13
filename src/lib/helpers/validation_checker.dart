import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:kira_auth/models/export.dart';

class ValidationChecker {
  static bool checkDecodedMsgValidation({
    @required Map<String, dynamic> decoded,
    @required StdEncodeMessage stdEncodeMsg,
  }) {
    if (decoded['account_number'] != stdEncodeMsg.accountNumber) {
      print("account number mismatch");
      return false;
    }

    if (decoded['chain_id'] != stdEncodeMsg.chainId) {
      print("chain id mismatch");
      return false;
    }

    if (decoded['sequence'] != stdEncodeMsg.sequence) {
      print("sequence mismatch");
      return false;
    }

    if (decoded['memo'] != stdEncodeMsg.tx.memo) {
      print("memo mismatch");
      return false;
    }

    if (jsonEncode(decoded['fee']) !=
        jsonEncode(stdEncodeMsg.tx.fee.toEncodeJson())) {
      print("fee mismatch");
      return false;
    }

    if (jsonEncode(decoded['msgs'])
            .contains(stdEncodeMsg.tx.msg[0].amount[0].amount) !=
        true) {
      print("messages mismatch");
      return false;
    }

    return true;
  }
}
