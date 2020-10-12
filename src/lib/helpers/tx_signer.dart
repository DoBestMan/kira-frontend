import 'dart:convert';
import 'dart:typed_data';

import 'package:kira_auth/utils/map_sorter.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/models/account.dart';
import 'package:kira_auth/models/node_info.dart';
import 'package:kira_auth/models/cosmos_account.dart';
import 'package:kira_auth/models/transactions/export.dart';

class TransactionSigner {
  /// Signs the given [stdTx] using the info contained inside the
  /// given [wallet] and returns a new [StdTx] containing the signatures
  /// inside it.
  static Future<StdTx> signStdTx(
    Account account,
    StdTx stdTx,
  ) async {
    // Get the account data and node info from the network
    final CosmosAccount cosmosAccount =
        await QueryService.getAccountData(account);

    StatusService service = StatusService();
    await service.getNodeStatus();

    // Sign all messages
    final signature = _getStdSignature(account, cosmosAccount, service.nodeInfo,
        stdTx.stdMsg.messages, stdTx.authInfo.stdFee, stdTx.stdMsg.memo);

    Single single = Single(mode: "SIGN_MODE_LEGACY_AMINO_JSON");
    ModeInfo modeInfo = ModeInfo(single: single);

    SignerInfo signerInfo = SignerInfo(
        publicKey: signature['publicKey'],
        modeInfo: modeInfo,
        sequence: cosmosAccount.sequence);

    stdTx.authInfo.signerInfos = [signerInfo];
    // Assemble the transaction
    return StdTx(
        stdMsg: stdTx.stdMsg,
        authInfo: stdTx.authInfo,
        signatures: [signature['signature']]);
  }

  static Map<String, dynamic> _getStdSignature(
    Account account,
    CosmosAccount cosmosAccount,
    NodeInfo nodeInfo,
    List<MsgSend> messages,
    StdFee fee,
    String memo,
  ) {
    // Create the signature object
    final signature = StdSignatureMessage(
      sequence: cosmosAccount.sequence, //checked
      accountNumber: cosmosAccount.accountNumber, //checked
      chainId: nodeInfo.network, //checked
      fee: fee, //checked
      msgs: messages,
      memo: memo,
    );

    print(cosmosAccount.accountNumber);
    print(nodeInfo.network);

    // Convert the signature to a JSON and sort it
    final jsonSignature = signature.toJson();
    final sortedJson = MapSorter.sort(jsonSignature);

    // Encode the sorted JSON to a string and get the bytes
    var jsonData = json.encode(sortedJson);
    final bytes = utf8.encode(jsonData);

    // Sign the data
    final signatureData = account.signTxData(Uint8List.fromList(bytes));

    // Get the compressed Base64 public key
    final pubKeyCompressed = account.ecPublicKey.Q.getEncoded(true);

    // Build the StdSignature
    return {
      'signature': base64Encode(signatureData),
      'publicKey': StdPublicKey(publicKey: base64Encode(pubKeyCompressed)),
    };
  }
}
