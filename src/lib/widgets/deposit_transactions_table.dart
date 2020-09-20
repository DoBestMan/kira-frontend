import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:kira_auth/models/transaction_model.dart';
import 'package:kira_auth/services/deposit_transaction_service.dart';
import 'package:kira_auth/utils/colors.dart';

class DepositTransactionsTable extends StatefulWidget {
  const DepositTransactionsTable({
    Key key,
  }) : super(key: key);

  @override
  _DepositTransactionsTableState createState() =>
      _DepositTransactionsTableState();
}

class _DepositTransactionsTableState extends State<DepositTransactionsTable> {
  DepositTransactionService transactionService = DepositTransactionService();
  List<TransactionModel> transactions;
  bool sort;
  Timer timer;
  int copiedIndex;

  @override
  void initState() {
    transactionService.getDummyTokens();
    sort = false;
    copiedIndex = -1;
    transactions = transactionService.transactions;
    super.initState();
  }

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 4) {
      if (ascending) {
        transactions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      } else {
        transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    }
  }

  void autoClear() {
    timer = new Timer(const Duration(seconds: 2), () {
      setState(() {
        copiedIndex = -1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columnSpacing: 40,
        sortAscending: sort,
        sortColumnIndex: 4,
        columns: [
          DataColumn(
            label: Flexible(
              child: Text("Transaction Hash",
                  style: TextStyle(color: KiraColors.purple1, fontSize: 17)),
            ),
            numeric: false,
            tooltip: "Transaction Hash",
          ),
          DataColumn(
            label: Flexible(
              child: Text("Token",
                  style: TextStyle(color: KiraColors.purple1, fontSize: 17)),
            ),
            numeric: false,
            tooltip: "Asset Name",
          ),
          DataColumn(
            label: Flexible(
              child: Text("Status",
                  style: TextStyle(color: KiraColors.purple1, fontSize: 17)),
            ),
            numeric: false,
            tooltip: "Status",
          ),
          DataColumn(
            label: Flexible(
              child: Text("Deposit Amount",
                  style: TextStyle(color: KiraColors.purple1, fontSize: 17)),
            ),
            numeric: false,
            tooltip: "Deposit Amount",
          ),
          DataColumn(
              label: Flexible(
                child: Text("Timestamp",
                    style: TextStyle(color: KiraColors.purple1, fontSize: 17)),
              ),
              numeric: false,
              tooltip: "Timestamp",
              onSort: (columnIndex, ascending) {
                setState(() {
                  sort = !sort;
                });
                onSortColum(columnIndex, ascending);
              }),
          DataColumn(
            label: Flexible(
              child: Text("From",
                  style: TextStyle(color: KiraColors.purple1, fontSize: 17)),
            ),
            numeric: false,
            tooltip: "From Address",
          ),
        ],
        rows: transactions
            .asMap()
            .entries
            .map((entry) {
              var index = entry.key;
              var token = entry.value;
              return DataRow(cells: [
                DataCell(Container(
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          width: 250,
                          child: Text(token.hash,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: KiraColors.black.withOpacity(0.8),
                                  fontSize: 15)),
                        ),
                      ),
                      Text(
                          token.hash
                              .toString()
                              .substring((token.hash).length - 5),
                          style: TextStyle(
                              color: KiraColors.black.withOpacity(0.8),
                              fontSize: 15)),
                      IconButton(
                          icon: Icon(Icons.copy),
                          color: copiedIndex == index
                              ? KiraColors.green2
                              : KiraColors.kBrownColor,
                          onPressed: () {
                            FlutterClipboard.copy(token.hash).then((value) => {
                                  setState(() {
                                    copiedIndex = index;
                                  }),
                                  if (copiedIndex > -1) {autoClear()}
                                });
                          }),
                    ],
                  ),
                  width: 300,
                )),
                DataCell(
                  Text(token.token,
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 15)),
                ),
                DataCell(
                  Text(token.status,
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 15)),
                ),
                DataCell(
                  Text(token.depositAmount,
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 15)),
                ),
                DataCell(
                  Text(token.timestamp,
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 15)),
                ),
                DataCell(
                  Text(token.from,
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 15)),
                ),
              ]);
            })
            .toSet()
            .toList(),
      ),
    );
  }
}
