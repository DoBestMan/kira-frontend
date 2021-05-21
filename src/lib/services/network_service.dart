import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/config.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/utils/cache.dart';

class NetworkService {
  List<Validator> validators = [];
  int totalCount = 0;
  int lastOffset = 0;

  List<Block> blocks = [];
  Block block;

  int latestBlockHeight = 0;
  int lastBlockOffset = 0;

  List<BlockTransaction> transactions = [];
  BlockTransaction transaction;

  Future<void> getValidatorsCount() async {
    var apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl[0] + "/valopers?count_total=true",
        headers: {'Access-Control-Allow-Origin': apiUrl[1]});

    var bodyData = json.decode(data.body);
    if (!bodyData.containsKey('pagination')) return;

    totalCount = int.parse(bodyData['pagination']['total'] ?? '0');
  }

  Future<void> getValidators(bool loadNew) async {
    List<Validator> validatorList = [];

    var apiUrl = await loadInterxURL();
    var offset, limit;
    if (loadNew) {
      offset = totalCount;
      await getValidatorsCount();
      limit = totalCount - offset;
    } else {
      if (lastOffset == 0) {
        await getValidatorsCount();
        lastOffset = totalCount;
      }
      offset = max(lastOffset - 20, 0);
      limit = lastOffset - offset;
      lastOffset = offset;
    }
    if (limit == 0) return;

    var data = await http.get(apiUrl[0] + "/valopers?offset=$offset&limit=$limit&count_total=true", headers: {'Access-Control-Allow-Origin': apiUrl[1]});

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
        rank: validators[i]['rank'] != null ? int.parse(validators[i]['rank']) : 0,
        streak: validators[i]['streak'] != null ? int.parse(validators[i]['streak']) : 0,
        mischance: validators[i]['mischance'] != null ? int.parse(validators[i]['mischance']) : 0,
      );
      validatorList.add(validator);
    }

    this.validators.addAll(validatorList);
    sortValidators();
    this.validators.sort((a, b) => a.top.compareTo(b.top));
  }

  sortValidators() {
    validators.sort((a, b) {
      if (a.getStatus() != b.getStatus()) {
        if (b.getStatus() == ValidatorStatus.ACTIVE)
          return 1;
        if (a.getStatus() == ValidatorStatus.ACTIVE)
          return -1;
        return a.getStatus().toString().compareTo(b.getStatus().toString());
      }
      if (a.rank != b.rank) {
        if (a.rank == 0)
          return 1;
        if (b.rank == 0)
          return -1;
        return a.rank.compareTo(b.rank);
      }
      if (a.streak != b.streak)
        return a.streak.compareTo(b.streak);

      return -1;
    });
    var top = 1;
    validators.forEach((element) { element.top = top ++; });
  }

  Future<Validator> searchValidator(String proposer) async {
    var apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl[0] + "/valopers?proposer=$proposer",
        headers: {'Access-Control-Allow-Origin': apiUrl[1]});

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

  Future<void> getBlocks(bool loadNew) async {
    List<Block> blockList = [];

    var statusService = StatusService();
    await statusService.getNodeStatus();
    var offset, limit;
    if (loadNew) {
      offset = latestBlockHeight;
      latestBlockHeight = int.parse(statusService.syncInfo.latestBlockHeight);
      limit = latestBlockHeight - offset;
    } else {
      if (lastBlockOffset == 0)
        lastBlockOffset = latestBlockHeight = int.parse(statusService.syncInfo.latestBlockHeight);
      offset = max(lastBlockOffset - 20, 0);
      limit = lastBlockOffset - offset;
      lastBlockOffset = offset;
    }
    if (limit == 0) return;

    var apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl[0] + '/blocks?minHeight=${offset + 1}&maxHeight=${offset + limit}',
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

    this.blocks.addAll(blockList);
    this.blocks.sort((a, b) => b.height.compareTo(a.height));
  }

  Future<void> searchTransaction(String query) async {
    transaction = null;
    var apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl[0] + '/transactions/$query', headers: {'Access-Control-Allow-Origin': apiUrl[1]});
    var bodyData = json.decode(data.body);
    if (bodyData.containsKey("code")) return;
    transaction = BlockTransaction.fromJson(bodyData);
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
        BlockTransaction transaction = BlockTransaction.fromJson(transactions[i]);
        transactionList.add(transaction);
      }

      this.transactions = transactionList;
      storeTransactions(height, transactionList);
    }
  }
}
