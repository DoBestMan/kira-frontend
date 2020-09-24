import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kira_auth/models/transaction_model.dart';

class WithdrawalTransactionService {
  List<TransactionModel> transactions = List();

  Future<void> getTokens({hash}) async {
    List<TransactionModel> transactions;

    var data = await http.get("http://0.0.0.0:11000/api/cosmos/tx/$hash");

    var jsonData = json.decode(data.body);

    transactions.add(TransactionModel.fromJson(jsonData['response']));
  }

  void getDummyTokens() {
    var transactionData = [
      {
        "token": 'kex',
        "hash":
            '0xfe5c42ec8d0a5dc73e1191bf766fcf3f526a019cd529bb6a5b8263ab48004f1e',
        'status': 'success',
        "deposit_amount": '50',
        "timestamp": '2020-09-17',
        'to': 'kira5s3dug5sh7hrfz65hee2gcgh6rtestrtuurtqe8',
        'fee': '0.25'
      },
      {
        "token": 'kex',
        "hash":
            '0xhe5c42e78d4a5dc73e1191bf766fcf3f526a019cd5dj5j2dhb8263ab48004f13',
        'status': 'success',
        "deposit_amount": '10',
        "timestamp": '2020-09-16',
        'to': 'kira1spdug5u0ph7jfz0eeegcp62tsptjkl2dqejaz7',
        'fee': '0.25'
      },
    ];

    for (int i = 0; i < transactionData.length; i++) {
      TransactionModel transaction =
          TransactionModel.fromJson(transactionData[i]);
      transactions.add(transaction);
    }
  }
}