import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/config.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/utils/cache.dart';

class NetworkService {
  List<Validator> validators = [];

  List<Block> blocks = [];
  Block block;

  List<BlockTransaction> transactions = [];
  BlockTransaction transaction;

  int latestBlockHeight = 0;

  Future<void> getValidators() async {
    this.validators = [];
    List<Validator> validatorList = [];

    var apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl[0] + "/valopers", headers: {'Access-Control-Allow-Origin': apiUrl[1]});

    var bodyData = json.decode(data.body);
    if (!bodyData.containsKey('validators')) return;
    var validators = bodyData['validators'];

    for (int i = 0; i < validators.length; i++) {
      Validator validator = Validator(
        address: validators[i]['address'],
        valkey: validators[i]['valkey'],
        pubkey: validators[i]['pubkey'],
        moniker: validators[i]['moniker'],
        website: validators[i]['website'] ?? "",
        social: validators[i]['social'] ?? "",
        identity: validators[i]['identity'] ?? "",
        commission: double.parse(validators[i]['commission'] ?? "0"),
        status: validators[i]['status'],
        top: validators[i]['top'] != null ? int.parse(validators[i]['top']) : 0,
        rank: validators[i]['rank'] != null ? int.parse(validators[i]['rank']) : 0,
        streak: validators[i]['streak'] != null ? int.parse(validators[i]['streak']) : 0,
        mischance: validators[i]['mischance'] != null ? int.parse(validators[i]['mischance']) : 0,
      );
      validatorList.add(validator);
    }

    validatorList.sort((a, b) => a.top.compareTo(b.top));
    this.validators = validatorList;
  }

  Future<Validator> searchValidator(String proposer) async {
    var apiUrl = await loadInterxURL();
    var data =
        await http.get(apiUrl[0] + "/valopers?proposer=$proposer", headers: {'Access-Control-Allow-Origin': apiUrl[1]});

    var bodyData = json.decode(data.body);
    if (!bodyData.containsKey("validators")) return null;
    var validator = bodyData['validators'][0];

    return Validator(
      address: validator['address'],
      valkey: validator['valkey'],
      pubkey: validator['pubkey'],
      moniker: validator['moniker'],
      website: validator['website'] ?? "",
      social: validator['social'] ?? "",
      identity: validator['identity'] ?? "",
      commission: double.parse(validator['commission'] ?? "0"),
      status: validator['status'],
      top: int.parse(validator['top'] ?? "0"),
      rank: int.parse(validator['rank'] ?? "0"),
      streak: int.parse(validator['streak'] ?? "0"),
      mischance: int.parse(validator['mischance'] ?? "0"),
    );
  }

  Future<void> getBlocks() async {
    this.blocks = [];
    List<Block> blockList = [];

    var statusService = StatusService();
    await statusService.getNodeStatus();
    var latestHeight = int.parse(statusService.syncInfo.latestBlockHeight);
    var minHeight = max(latestBlockHeight, latestHeight - 10);
    latestBlockHeight = latestHeight;
    var apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl[0] + '/blocks?minHeight=${minHeight + 1}&maxHeight=$latestHeight',
        headers: {'Access-Control-Allow-Origin': apiUrl[1]});

    var bodyData = json.decode(data.body);
    if (!bodyData.containsKey("block_metas")) return;
    var blocks = bodyData['block_metas'];

    for (int i = 0; i < blocks.length; i++) {
      var header = blocks[i]['header'];
      Block block = Block(
        blockSize: int.parse(blocks[i]['block_size']),
        txAmount: int.parse(blocks[i]['num_txs']),
        hash: blocks[i]['block_id']['hash'],
        appHash: header['app_hash'],
        chainId: header['chain_id'],
        consensusHash: header['consensus_hash'],
        dataHash: header['data_hash'],
        evidenceHash: header['evidence_hash'],
        height: int.parse(header['height']),
        lastCommitHash: header['last_commit_hash'],
        lastResultsHash: header['last_results_hash'],
        nextValidatorsHash: header['next_validators_hash'],
        proposerAddress: header['proposer_address'],
        validatorsHash: header['validators_hash'],
        time: DateTime.parse(header['time'] ?? DateTime.now().toString()),
      );
      block.validator = await searchValidator(block.proposerAddress);
      blockList.add(block);
    }

    this.blocks = blockList;
  }

  Future<void> searchTransaction(String query) async {
    transaction = null;
    var apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl[0] + '/transactions/$query', headers: {'Access-Control-Allow-Origin': apiUrl[1]});
    var bodyData = json.decode(data.body);
    if (bodyData.containsKey("code")) return;
    transaction = BlockTransaction.parse(bodyData);
    if (transaction.blockHeight == 0) transaction = null;
  }

  Future<void> searchBlock(String query) async {
    block = null;
    var apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl[0] + '/blocks/$query', headers: {'Access-Control-Allow-Origin': apiUrl[1]});
    var bodyData = json.decode(data.body);
    if (bodyData.containsKey("code"))
      await getTransactions(-1);
    else {
      var txAmount = (bodyData['block']['data']['txs'] as List).length;

      var header = bodyData['block']['header'];
      block = Block(
        blockSize: 1,
        txAmount: txAmount,
        hash: bodyData['block_id']['hash'],
        appHash: header['app_hash'],
        chainId: header['chain_id'],
        consensusHash: header['consensus_hash'],
        dataHash: header['data_hash'],
        evidenceHash: header['evidence_hash'],
        height: int.parse(header['height']),
        lastCommitHash: header['last_commit_hash'],
        lastResultsHash: header['last_results_hash'],
        nextValidatorsHash: header['next_validators_hash'],
        proposerAddress: header['proposer_address'],
        validatorsHash: header['validators_hash'],
        time: DateTime.parse(header['time'] ?? DateTime.now().toString()),
      );
      block.validator = await searchValidator(block.proposerAddress);
      await getTransactions(block.height);
    }
  }

  Future<void> getTransactions(int height) async {
    if (height < 0)
      this.transactions = List.empty();
    else if (await checkTransactionsExists(height))
      this.transactions = await getTransactionsForHeight(height);
    else {
      List<BlockTransaction> transactionList = [];

      var apiUrl = await loadInterxURL();
      var data = await http
          .get(apiUrl[0] + '/blocks/$height/transactions', headers: {'Access-Control-Allow-Origin': apiUrl[1]});
      var bodyData = json.decode(data.body);
      var transactions = bodyData['txs'];

      for (int i = 0; i < transactions.length; i++) {
        BlockTransaction transaction = BlockTransaction.parse(transactions[i]);
        transactionList.add(transaction);
      }

      this.transactions = transactionList;
      storeTransactions(height, transactionList);
    }
  }
}
