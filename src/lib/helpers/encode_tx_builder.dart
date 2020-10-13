import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/services/export.dart';

class EncodeTransactionBuilder {
  static Future<StdEncodeMessage> buildEncodeTx(
    Account account,
    List<MsgSend> messages, {
    String memo = '',
    StdFee stdFee,
  }) async {
    // Validate the messages
    messages.forEach((msg) {
      final error = msg.validate();
      if (error != null) {
        throw error;
      }
    });

    final CosmosAccount cosmosAccount =
        await QueryService.getAccountData(account);

    StatusService service = StatusService();
    await service.getNodeStatus();

    final stdEncodeTx =
        StdEncodeTx(msg: messages, fee: stdFee, signatures: null, memo: memo);

    return StdEncodeMessage(
        chainId: service.nodeInfo.network,
        accountNumber: cosmosAccount.accountNumber,
        sequence: cosmosAccount.sequence,
        tx: stdEncodeTx);
  }
}
