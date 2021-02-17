import 'dart:convert';
import 'dart:math';
import 'dart:ui';
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

  Future<void> getValidators({ bool includesDummy = false }) async {
    List<Validator> validatorList = [];

    String apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl + "/valopers");

    var bodyData = json.decode(data.body);
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
        rank: validators[i]['rank'] ?? 0,
        streak: validators[i]['streak'] ?? 0,
        mischance: validators[i]['mischance'] ?? 0,
      );
      validatorList.add(validator);
    }

    if (includesDummy) {
      validatorList.add(Validator(
        address: "kira1tuv9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1tuv9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "test 3",
        website: "",
        social: "social",
        identity: "",
        commission: 0.0003462,
        status: "ACTIVE",
        rank: 5,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1wer9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1wer9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "kira",
        website: "",
        social: "social",
        identity: "",
        commission: 0.2626723,
        status: "INACTIVE",
        rank: 6,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1oij9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1oij9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "ongoing",
        website: "",
        social: "social",
        identity: "",
        commission: 0.2357255234,
        status: "UNDEFINED",
        rank: 9,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1aps9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1aps9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "total",
        website: "",
        social: "social",
        identity: "",
        commission: 0.0000346234,
        status: "PAUSED",
        rank: 3,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1gow9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1gow9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "network",
        website: "",
        social: "social",
        identity: "",
        commission: 0.94674,
        status: "INACTIVE",
        rank: 8,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1pip9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1pip9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "knife",
        website: "",
        social: "social",
        identity: "",
        commission: 0.54672346,
        status: "PAUSED",
        rank: 1,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1bwc9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1bwc9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "moon",
        website: "",
        social: "social",
        identity: "",
        commission: 0.116346,
        status: "ACTIVE",
        rank: 2,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1wfw9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1wfw9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "testnet",
        website: "",
        social: "social",
        identity: "",
        commission: 0.88256,
        status: "ACTIVE",
        rank: 7,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1gwn9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1gwn9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "everyone",
        website: "",
        social: "social",
        identity: "",
        commission: 0.14367782345,
        status: "UNDEFINED",
        rank: 4,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1qqx9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1qqx9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "guy",
        website: "",
        social: "social",
        identity: "",
        commission: 0.098593556345,
        status: "INACTIVE",
        rank: 15,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1vop9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1vop9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "working",
        website: "",
        social: "social",
        identity: "",
        commission: 0.8654634,
        status: "INACTIVE",
        rank: 12,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1mkf9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1mkf9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "last",
        website: "",
        social: "social",
        identity: "",
        commission: 0.6623454532,
        status: "ACTIVE",
        rank: 14,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1ntr9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1ntr9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "middle",
        website: "",
        social: "social",
        identity: "",
        commission: 0.1534667,
        status: "PAUSED",
        rank: 11,
        streak: 1,
        mischance: 1
      ));
      validatorList.add(Validator(
        address: "kira1lwty9pcmlnywlpphj8vtm0j0alhrrjwjsdxmjts",
        valkey: "kiravaloper1lwty9pcmlnywlpphj8vtm0j0alhrrjwjs7q83nu",
        pubkey: "kiravalconspub1zcjduepqm98ffgul4ppzzur6l67v3mj2vsyc7tr9nrzwk3e0ffx0z7l9sgsqnln467",
        moniker: "confirm",
        website: "",
        social: "social",
        identity: "",
        commission: 0.445235235,
        status: "ACTIVE",
        rank: 13,
        streak: 1,
        mischance: 1
      ));
    }

    validatorList.sort((a, b) => a.rank.compareTo(b.rank));
    this.validators = validatorList;
  }

  Future<Validator> searchValidator(String proposer) async {
    String apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl + "/valopers?proposer=$proposer");

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
      rank: validator['rank'] ?? 0,
      streak: validator['streak'] ?? 0,
      mischance: validator['mischance'] ?? 0,
    );
  }

  Future<void> getBlocks() async {
    List<Block> blockList = [];

    var statusService = StatusService();
    await statusService.getNodeStatus();
    var latestHeight = int.parse(statusService.syncInfo.latestBlockHeight);
    var minHeight = max(latestBlockHeight, latestHeight - 10);
    latestBlockHeight = latestHeight;
    String apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl + '/blocks?minHeight=${minHeight + 1}&maxHeight=$latestHeight');

    var bodyData = json.decode(data.body);
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
    String apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl + '/transactions/$query');
    var bodyData = json.decode(data.body);
    if (bodyData.containsKey("code")) return;
    transaction = BlockTransaction.parse(bodyData);
  }

  Future<void> searchBlock(String query) async {
    block = null;
    String apiUrl = await loadInterxURL();
    var data = await http.get(apiUrl + '/blocks/$query');
    var bodyData = json.decode(data.body);
    if (bodyData.containsKey("code")) await getTransactions(-1);
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

      String apiUrl = await loadInterxURL();
      var data = await http.get(apiUrl + '/blocks/$height/transactions');
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
