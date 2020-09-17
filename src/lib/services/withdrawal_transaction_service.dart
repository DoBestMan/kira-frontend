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
        "deposit_amount": '632',
        "timestamp": '2020-09-17',
        "hash": 'j286k4hnd90g4h2bhaslw975n9dfu4364kg',
      },
      {
        "deposit_amount": '30',
        "timestamp": '2020-09-17',
        "hash": '2abyt4gow32n536jo220fheb6843ngxdet4',
      },
    ];

    for (int i = 0; i < transactionData.length; i++) {
      TransactionModel transaction =
          TransactionModel.fromJson(transactionData[i]);
      transactions.add(transaction);
    }
  }
}
