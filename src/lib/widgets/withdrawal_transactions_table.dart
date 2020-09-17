import 'package:flutter/material.dart';
import 'package:kira_auth/models/transaction_model.dart';
import 'package:kira_auth/services/withdrawal_transaction_service.dart';
import 'package:kira_auth/utils/colors.dart';

class WithdrawalTransactionsTable extends StatefulWidget {
  const WithdrawalTransactionsTable({
    Key key,
  }) : super(key: key);

  @override
  _WithdrawalTransactionsTableState createState() =>
      _WithdrawalTransactionsTableState();
}

class _WithdrawalTransactionsTableState
    extends State<WithdrawalTransactionsTable> {
  WithdrawalTransactionService transactionService =
      WithdrawalTransactionService();
  List<TransactionModel> transactions;
  bool sort;

  @override
  void initState() {
    transactionService.getDummyTokens();
    sort = false;
    transactions = transactionService.transactions;
    super.initState();
  }

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        transactions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      } else {
        transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      margin: EdgeInsets.only(bottom: 30),
      child: SizedBox(
          height: 200,
          width: screenSize.width,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              verticalDirection: VerticalDirection.up,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      showCheckboxColumn: false,
                      columnSpacing: 90,
                      sortAscending: sort,
                      sortColumnIndex: 0,
                      columns: [
                        DataColumn(
                            label: Text("Timestamp",
                                style: TextStyle(
                                    color: KiraColors.purple1, fontSize: 20)),
                            numeric: false,
                            tooltip: "Timestamp",
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                              });
                              onSortColum(columnIndex, sort);
                            }),
                        DataColumn(
                          label: Text("Transaction Hash",
                              style: TextStyle(
                                  color: KiraColors.purple1, fontSize: 20)),
                          numeric: false,
                          tooltip: "Transaction Hash",
                        ),
                        DataColumn(
                          label: Text("Deposit Amount",
                              style: TextStyle(
                                  color: KiraColors.purple1, fontSize: 20)),
                          numeric: false,
                          tooltip: "Deposit Amount",
                        ),
                      ],
                      rows: transactions
                          .map(
                            (token) => DataRow(cells: [
                              DataCell(
                                Text(token.timestamp,
                                    style: TextStyle(
                                        color: KiraColors.black, fontSize: 18)),
                              ),
                              DataCell(
                                Text(token.hash,
                                    style: TextStyle(
                                        color: KiraColors.black, fontSize: 18)),
                              ),
                              DataCell(
                                Text(token.depositAmount,
                                    style: TextStyle(
                                        color: KiraColors.black, fontSize: 18)),
                              ),
                            ]),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ])),
    );
  }
}
