import 'package:kira_auth/utils/map_sorter.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/models/account.dart';
import 'package:kira_auth/models/node_info.dart';
import 'package:kira_auth/models/cosmos_account.dart';
import 'package:kira_auth/models/transactions/export.dart';

//  Library used to separate Online Transcation Signer into separate components
// Depending on whether they are online or offline. This is required to built an offline signer
class TransactionOfflineSigner {
  // Retrieves online Account's information [AccountNumber, Sequence]
  static Future<Map<String, dynamic>> getOnlineInformation(
    Account account,
    StdTx stdTx,
  ) async {
    // Get the account data and node info from the network
    final CosmosAccount cosmosAccount = await QueryService.getAccountData(account);
    StatusService service = StatusService();
    await service.getNodeStatus();
    final signature = _getSortedJson(
      account,
      cosmosAccount,
      service.nodeInfo,
      stdTx.stdMsg.messages,
      stdTx.authInfo.stdFee,
      stdTx.stdMsg.memo,
    );
    return signature;
  }

  // This is one of the separated components from TranscationOnlineSigner
  // This returns the structured JSON data that needs to be signed by an Offline device
  static Map<String, dynamic> _getSortedJson(
    Account account,
    CosmosAccount cosmosAccount,
    NodeInfo nodeInfo,
    List<MsgSend> messages,
    StdFee fee,
    String memo,
  ) {
    final signature = StdSignatureMessage(
      sequence: cosmosAccount.sequence,
      accountNumber: cosmosAccount.accountNumber,
      chainId: nodeInfo.network,
      fee: fee,
      msgs: messages,
      memo: memo,
    );
    final jsonSignature = signature.toJson();
    final sortedJson = MapSorter.sort(jsonSignature);

    return sortedJson;
  }

  // The second separated component, this retrieves the signed and structured transcation from an offline device
  // and processes the rest of the code required. Before it can be broadcasted
  static Future<StdTx> signOfflineStdTx(Account account, StdTx stdTx, var signature) async {
    final CosmosAccount cosmosAccount = await QueryService.getAccountData(account);

    StatusService service = StatusService();
    await service.getNodeStatus();

    Single single = Single(mode: "SIGN_MODE_LEGACY_AMINO_JSON");
    ModeInfo modeInfo = ModeInfo(single: single);

    StdPublicKey person = StdPublicKey(key: signature['publicKey'].key, type: signature['publicKey'].type);
    SignerInfo signerInfo = SignerInfo(publicKey: person, modeInfo: modeInfo, sequence: cosmosAccount.sequence);

    stdTx.authInfo.signerInfos = [
      signerInfo
    ];
    return StdTx(stdMsg: stdTx.stdMsg, authInfo: stdTx.authInfo, signatures: [
      signature['signature']
    ]);
  }
}
