import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/transaction.dart';

class WithdrawalTransactionService {
  List<Transaction> transactions = List();

  Future<void> getWithdrawalTransaction({hash}) async {
    Transaction transaction = Transaction();

    if (hash.length < 64) return;

    var data = await http.get("http://0.0.0.0:11000/api/cosmos/txs/$hash");

    var jsonData = jsonDecode(data.body);

    if (jsonData['message'] == "Internal error") {
      print("No transaction exists for the hash");
      return;
    }

    transaction.hash = "0x" + jsonData['hash'];
    transaction.gas = jsonData['gas_used'];
    transaction.status = "success";
    transaction.timestamp = "2020-10-12";

    for (var events in jsonData['tx_result']['events']) {
      for (var attribute in events['attributes']) {
        String key = attribute['key'];
        String value = attribute['value'];

        key = utf8.decode(base64Decode(key));
        value = utf8.decode(base64Decode(value));

        if (key == "action") transaction.action = value;
        if (key == "sender") transaction.sender = value;
        if (key == "recipient") transaction.recipient = value;
        if (key == 'module') transaction.module = value;
        if (key == "amount") {
          transaction.amount = value.split(new RegExp(r'[^0-9]+')).first;
          transaction.token = value.split(new RegExp(r'[^a-z]+')).last;
        }
      }
    }

    transactions.add(transaction);
  }

  void getDummyTransactions() {
    var transactionData = [
      {
        "hash":
            '0xfe5c42ec8d0a5dc73e1191bf766fcf3f526a019cd529bb6a5b8263ab48004f1e',
        "action": 'send',
        'sender': '',
        'recipient': 'kira5s3dug5sh7hrfz65hee2gcgh6rtestrtuurtqe8',
        "token": 'stake',
        "amount": '50',
        'module': 'bank',
        'gas': '63225',
        'status': 'success',
        "timestamp": '2020-09-17',
      },
      {
        "hash":
            '0xhe5c42e78d4a5dc73e1191bf766fcf3f526a019cd5dj5j2dhb8263ab48004f13',
        "action": 'send',
        'sender': '',
        'recipient': 'kira1spdug5u0ph7jfz0eeegcp62tsptjkl2dqejaz7',
        "token": 'validatortoken',
        "amount": '60',
        'module': 'bank',
        'gas': '53534',
        'status': 'success',
        "timestamp": '2020-09-16',
      },
    ];

    for (int i = 0; i < transactionData.length; i++) {
      Transaction transaction = Transaction.fromJson(transactionData[i]);
      transactions.add(transaction);
    }
  }
}
