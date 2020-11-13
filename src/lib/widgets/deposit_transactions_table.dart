import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:kira_auth/models/transaction.dart';
import 'package:kira_auth/utils/colors.dart';

class DepositTransactionsTable extends StatefulWidget {
  final List<Transaction> transactions;
  DepositTransactionsTable({
    Key key,
    this.transactions,
  }) : super();

  @override
  _DepositTransactionsTableState createState() =>
      _DepositTransactionsTableState();
}

class _DepositTransactionsTableState extends State<DepositTransactionsTable> {
  bool sort;
  Timer timer;
  int copiedIndex;

  @override
  void initState() {
    super.initState();

    sort = false;
    copiedIndex = -1;
  }

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 4) {
      if (ascending) {
        widget.transactions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      } else {
        widget.transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
              child: Text("Amount",
                  style: TextStyle(color: KiraColors.purple1, fontSize: 17)),
            ),
            numeric: false,
            tooltip: "Deposit Amount",
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
              child: Text("Sender",
                  style: TextStyle(color: KiraColors.purple1, fontSize: 17)),
            ),
            numeric: false,
            tooltip: "Sender Address",
          ),
        ],
        rows: widget.transactions
            .asMap()
            .entries
            .map((entry) {
              var index = entry.key;
              var token = entry.value;
              String tokenHash = token.hash.toLowerCase();
              return DataRow(cells: [
                DataCell(Container(
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        margin: EdgeInsets.only(right: 10),
                        child: Text("new",
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: KiraColors.orange1,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                      Flexible(
                        child: Container(
                          width: 280,
                          child: Text(
                              tokenHash.replaceRange(
                                  26, tokenHash.length - 4, '....'),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: KiraColors.black.withOpacity(0.8),
                                  fontSize: 14)),
                        ),
                      ),
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
                  width: 320,
                )),
                DataCell(
                  Text(token.token,
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 14)),
                ),
                DataCell(
                  Text(token.amount,
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 14)),
                ),
                DataCell(
                  Text(token.status,
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 14)),
                ),
                DataCell(
                  Text(token.timestamp,
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 14)),
                ),
                DataCell(
                  Text(token.sender,
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 14)),
                ),
              ]);
            })
            .toSet()
            .toList(),
      ),
    );
  }
}
