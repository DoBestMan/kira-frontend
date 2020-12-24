import 'dart:convert';
// import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/transaction.dart';
import 'package:kira_auth/config.dart';
import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';
import 'package:kira_auth/services/export.dart';
import 'package:secp256k1/secp256k1.dart';
// import 'package:ontology_dart_sdk/crypto.dart' as Crypto;

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
    var interxPubKeyList = base64Decode(interxPubKey);
    String interxPublicKey = HEX.encode(interxPubKeyList);
    print("INTERX PUBKEY: $interxPublicKey");

    var config = await loadConfig();
    String apiUrl = json.decode(config)['api_url'];

    String url = isWithdrawal == true ? "withdraws" : "deposits";
    String bech32Address = account.bech32Address;

    var response = await http.get(apiUrl + "/$url?account=$bech32Address&&type=all&&max=$max");
    Map<String, dynamic> body = jsonDecode(response.body);
    var header = response.headers;

    // Interx Signature
    var interxSignature = header['interx_signature'];
    var hexInterxSignature = HEX.encode(base64Decode(interxSignature));
/*

    var toBeVerified = {
      'chain_id': header['interx_chain_id'],
      'block': header['interx_block'],
      'block_time': header['interx_blocktime'],
      'timestamp': header['interx_timestamp'],
      'response': header['interx_hash']
    };

    var message = utf8.encode(jsonEncode(toBeVerified));

    var hashedSignature = sha256.convert(utf8.encode(interxSignature)).toString();
    var dSignature = base64Decode(hashedSignature);
    var decodedSignatureToList = List<int>.from(dSignature);
    decodedSignatureToList.insert(0, 1);
    var decodedSignature = Uint8List.fromList(decodedSignatureToList);

    Crypto.Signature signature = Crypto.Signature.fromBytes(decodedSignature);
    print(signature.r);
    print(signature.s);
    print(signature.algorithm);
    Crypto.PublicKey pubKey = Crypto.PublicKey.fromHex(interxPublicKey);
    print(pubKey);
    Crypto.Curve curve = Crypto.Curve.fromValue(25);
    var verifyResult = await Crypto.Ecdsa.verify(message, signature, interxPubKeyList, curve);
    // var verifyResult = pubKey.verify(message, signature);
    print(verifyResult);

*/

    // Get PublicKey Object
    var privKey = PrivateKey.fromHex('a6e9dd381a0440feb331d2f0bdbb3a6b830cb81e31ce2724ba9d531cfedd5f13');
    var pubKey = PublicKey.fromCompressedHex(interxPublicKey);

    var hashedSignature = sha256.convert(utf8.encode(interxSignature)).toString();
    print(hashedSignature);
    var sigObj = privKey.signature(hashedSignature);
    var toHex = sigObj.toHexes();
    // var toRawHex = sig.toRawHex();
    // var toString = sig.toString();
    // var toBigInt = sig.toBigInts();
    print("HEX     : $toHex");
    // print("RAW HEX : $toRawHex");
    // print("STRING  : $toString");
    // print("BINGINT : $toBigInt");

    // var length = hashedSignature.length ~/ 2;
    // var L = hashedSignature.substring(0, length);
    // var R = hashedSignature.substring(length, hashedSignature.length);
    // print("$L, $R");
    var isVerified = sigObj.verify(pubKey, hashedSignature);
    print(isVerified);

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
