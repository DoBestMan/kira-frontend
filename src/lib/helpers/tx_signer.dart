import 'dart:convert';

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
    final signatures = _getStdSignature(account, cosmosAccount,
        service.nodeInfo, stdTx.messages, stdTx.fee, stdTx.memo);

    // Assemble the transaction
    return StdTx(
      fee: stdTx.fee,
      memo: stdTx.memo,
      messages: stdTx.messages,
      signatures: [signatures],
    );
  }

  static StdSignature _getStdSignature(
    Account account,
    CosmosAccount accountData,
    NodeInfo nodeInfo,
    List<StdMsg> messages,
    StdFee fee,
    String memo,
  ) {
    // Create the signature object
    final signature = StdSignatureMessage(
      sequence: accountData.sequence,
      accountNumber: accountData.accountNumber,
      chainId: nodeInfo.network,
      fee: fee.toJson(),
      memo: memo,
      msgs: messages.map((msg) => msg.toJson()).toList(),
    );

    // Convert the signature to a JSON and sort it
    final jsonSignature = signature.toJson();
    final sortedJson = MapSorter.sort(jsonSignature);

    // Encode the sorted JSON to a string and get the bytes
    var jsonData = json.encode(sortedJson);
    final bytes = utf8.encode(jsonData);

    // Sign the data
    final signatureData = account.signTxData(bytes);

    // Get the compressed Base64 public key
    final pubKeyCompressed = account.ecPublicKey.Q.getEncoded(true);

    // Build the StdSignature
    return StdSignature(
      value: base64Encode(signatureData),
      publicKey: StdPublicKey(
        type: "tendermint/PubKeySecp256k1",
        value: base64Encode(pubKeyCompressed),
      ),
    );
  }
}
