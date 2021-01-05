import 'dart:convert';
// import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/transaction.dart';
import 'package:kira_auth/config.dart';
import 'package:hex/hex.dart';
import 'package:kira_auth/services/export.dart';

class TransactionService {
  Future<Transaction> getTransaction({hash}) async {
    Transaction transaction = Transaction();

    if (hash.length < 64) return null;

    var config = await loadConfig();
    String apiUrl = json.decode(config)['api_url'];

    var response = await http.get(apiUrl + "/cosmos/txs/$hash");

    var body = jsonDecode(response.body);

    if (body['message'] == "Internal error") {
      print("No transaction exists for the hash");
      return null;
    }

    transaction.hash = "0x" + body['hash'];
    transaction.gas = body['gas_used'];
    transaction.status = "success";
    transaction.timestamp = "2020/10/12";

    for (var events in body['tx_result']['events']) {
      for (var attribute in events['attributes']) {
        String key = attribute['key'];
        String value = attribute['value'];

        key = utf8.decode(base64Decode(key));
        value = utf8.decode(base64Decode(value));

        if (key == "action") transaction.action = value;
        if (key == "sender") transaction.sender = value;
        if (key == "recipient") transaction.recipient = value;
        if (key == "amount") {
          transaction.amount = value.split(new RegExp(r'[^0-9]+')).first;
          transaction.token = value.split(new RegExp(r'[^a-z]+')).last;
        }
        transaction.isNew = false;
      }
    }

    return transaction;
  }

  Future<List<Transaction>> getTransactions({account, max, isWithdrawal, pubKey}) async {
    List<Transaction> transactions = [];

    StatusService service = StatusService();
    await service.getNodeStatus();
    String interxPubKey = service.interxPubKey;
    String interxPublicKey = HEX.encode(base64Decode(interxPubKey));
    print("INTERX PUBKEY: $interxPublicKey");

    var config = await loadConfig();
    String apiUrl = json.decode(config)['api_url'];

    String url = isWithdrawal == true ? "withdraws" : "deposits";
    String bech32Address = account.bech32Address;

    var response = await http.get(apiUrl + "/$url?account=$bech32Address&&type=all&&max=$max");
    Map<String, dynamic> body = jsonDecode(response.body);
    // var header = response.headers;

    // Interx Signature
    // var interxSignature = header['interx_signature'];
    // var interxSignatureBytes = base64Decode(interxSignature);
    // var interxSignatureHex = HEX.encode(interxSignatureBytes);

    // // Get PublicKey Object
    // var pubKey = PublicKey.fromCompressedHex(interxPublicKey);

    // var toBeVerified = {
    //   'chain_id': header['interx_chain_id'],
    //   'block': header['interx_block'],
    //   'block_time': header['interx_blocktime'],
    //   'timestamp': header['interx_timestamp'],
    //   'response': header['interx_hash']
    // };

    /**
      * interxSignature = "g/xnAv1ZpFSByOxxs9XC/F1AiXK5m8f3JNVYGcrf4IocHXc41chGg3+7bIjQU5OV3PwzIPKAWR1cSNheIMzO8w=="
      *   R = "83fc6702fd59a45481c8ec71b3d5c2fc5d408972b99bc7f724d55819cadfe08a"
      *   S = "1c1d7738d5c846837fbb6c88d0539395dcfc3320f280591d5c48d85e20cccef3"
      *
      *  interx_block = "3"
      *  interx_blocktime = "2020-12-25T01:11:10.057619Z"
      *  interx_chain_id = "testing"
      *  interx_timestamp = "1608858677"
      *  signbytes = "7b22636861696e5f6964223a2274657374696e67222c22626c6f636b223a332c22626c6f636b5f74696d65223a22323032302d31322d32355430313a31313a31302e3035373631395a222c2274696d657374616d70223a313630383835383637372c22726573706f6e7365223a2231423838344532363944323834374143353338414532363030413143444243464634334535313431363145414543364332313835354345354138313043323232227d"
      *  interx_hash = "1B884E269D2847AC538AE2600A1CDBCFF43E514161EAEC6C21855CE5A810C222"
      */

    // print("MESSAGE TO BE VERIFIED : $toBeVerified");

    // var jsonEncodedMsg = jsonEncode(toBeVerified);
    // print("JSON ENCODED : $jsonEncodedMsg");

    // var messageBytes = utf8.encode(jsonEncodedMsg);
    // print("ENCODED MESSAGE IN BYTES : $messageBytes");

    // var messageStr = utf8.encode(messageBytes.toString());
    // print("ENCODED MESSAGE IN STRING : $messageStr");

    // var hashOfMsg = sha256.convert(messageBytes).bytes;
    // var hexHashOfMsg = HEX.encode(hashOfMsg);
    // var sampleMessageHex =
    //     "7b22636861696e5f6964223a2274657374696e67222c22626c6f636b223a32342c22626c6f636b5f74696d65223a22323032302d31322d32355430313a32353a32382e3837323136315a222c2274696d657374616d70223a313630383835393534322c22726573706f6e7365223a2231423838344532363944323834374143353338414532363030413143444243464634334535313431363145414543364332313835354345354138313043323232227d";
    // var sampleOutput = HEX.encode(sha256.convert(HEX.decode(sampleMessageHex)).bytes);

    // print("sample out : $sampleOutput");
    // print("SHA256 OF MESSAGE : $hexHashOfMsg");

    // var length = interxSignatureHex.length ~/ 2;
    // var R = interxSignatureHex.substring(0, length);
    // var S = interxSignatureHex.substring(length, interxSignatureHex.length);
    // print("SIGNATURE : $R, $S");

    // var isVerified = Signature.fromHexes(R, S).verify(pubKey, hexHashOfMsg);
    // print(isVerified);

    for (final hash in body.keys) {
      Transaction transaction = Transaction();

      transaction.hash = hash;
      transaction.status = "success";
      var time = new DateTime.fromMillisecondsSinceEpoch(body[hash]['time'] * 1000);
      transaction.timestamp = DateFormat('yyyy/MM/dd, hh:mm').format(time);
      transaction.token = body[hash]['txs'][0]['denom'];
      transaction.amount = body[hash]['txs'][0]['amount'].toString();

      if (isWithdrawal == true) {
        transaction.recipient = body[hash]['txs'][0]['address'];
      } else {
        transaction.sender = body[hash]['txs'][0]['address'];
      }

      transactions.add(transaction);
    }

    return transactions;
  }

  List<Transaction> getDummyWithdrawalTransactions() {
    List<Transaction> transactions = [];
    var transactionData = [
      {
        "hash": '0xfe5c42ec8d0a5dc73e1191bf766fcf3f526a019cd529bb6a5b8263ab48004f1e',
        "action": 'send',
        'sender': '',
        'recipient': 'kira5s3dug5sh7hrfz65hee2gcgh6rtestrtuurtqe8',
        "token": 'stake',
        "amount": '50',
        'isNew': false,
        'gas': '63225',
        'status': 'success',
        "timestamp": '2020/09/17',
      },
      {
        "hash": '0xhe5c42e78d4a5dc73e1191bf766fcf3f526a019cd5dj5j2dhb8263ab48004f13',
        "action": 'send',
        'sender': '',
        'recipient': 'kira1spdug5u0ph7jfz0eeegcp62tsptjkl2dqejaz7',
        "token": 'validatortoken',
        "amount": '60',
        'isNew': false,
        'gas': '53534',
        'status': 'success',
        "timestamp": '2020/09/16',
      },
    ];

    for (int i = 0; i < transactionData.length; i++) {
      Transaction transaction = Transaction.fromJson(transactionData[i]);
      transactions.add(transaction);
    }
    return transactions;
  }

  List<Transaction> getDummyDepositTransactions() {
    List<Transaction> transactions = [];

    var transactionData = [
      {
        "hash": '0xfe5c42ec8d0a5dc73e1191bf766fcf3f526a019cd529bb6a5b8263ab48004f1e',
        "action": 'send',
        'recipient': '',
        'sender': 'kira5s3dug5sh7hrfz65hee2gcgh6rtestrtuurtqe8',
        "token": 'stake',
        "amount": '50',
        'isNew': false,
        'gas': '63225',
        'status': 'success',
        "timestamp": '2020/09/17',
      },
      {
        "hash": '0xhe5c42e78d4a5dc73e1191bf766fcf3f526a019cd5dj5j2dhb8263ab48004f13',
        "action": 'send',
        'recipient': '',
        'sender': 'kira1spdug5u0ph7jfz0eeegcp62tsptjkl2dqejaz7',
        "token": 'validatortoken',
        "amount": '60',
        'isNew': false,
        'gas': '53534',
        'status': 'success',
        "timestamp": '2020/09/16',
      },
    ];

    for (int i = 0; i < transactionData.length; i++) {
      Transaction transaction = Transaction.fromJson(transactionData[i]);
      transactions.add(transaction);
    }

    return transactions;
  }
}
