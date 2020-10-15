import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/transaction.dart';

class DepositTransactionService {
  Future<Transaction> getDepositTransaction({hash}) async {
    var data = await http.get("http://0.0.0.0:11000/api/cosmos/txs/$hash");

    var jsonData = json.decode(data.body);

    return Transaction.fromJson(jsonData);
  }

  List<Transaction> getDummyTransactions() {
    List<Transaction> transactions = List();
    var transactionData = [
      {
        "hash":
            '0xfe5c42ec8d0a5dc73e1191bf766fcf3f526a019cd529bb6a5b8263ab48004f1e',
        "action": 'send',
        'recipient': '',
        'sender': 'kira5s3dug5sh7hrfz65hee2gcgh6rtestrtuurtqe8',
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
        'recipient': '',
        'sender': 'kira1spdug5u0ph7jfz0eeegcp62tsptjkl2dqejaz7',
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

    return transactions;
  }
}
