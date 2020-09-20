import 'package:flutter/material.dart';
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

  @override
  void initState() {
    transactionService.getDummyTokens();
    sort = false;
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
                      columnSpacing: 40,
                      sortAscending: sort,
                      sortColumnIndex: 0,
                      columns: [
                        DataColumn(
                          label: Text("Transaction Hash",
                              style: TextStyle(
                                  color: KiraColors.purple1, fontSize: 20)),
                          numeric: false,
                          tooltip: "Transaction Hash",
                        ),
                        DataColumn(
                          label: Text("Token",
                              style: TextStyle(
                                  color: KiraColors.purple1, fontSize: 20)),
                          numeric: false,
                          tooltip: "Asset Name",
                        ),
                        DataColumn(
                          label: Text("Status",
                              style: TextStyle(
                                  color: KiraColors.purple1, fontSize: 20)),
                          numeric: false,
                          tooltip: "Status",
                        ),
                        DataColumn(
                          label: Text("Deposit Amount",
                              style: TextStyle(
                                  color: KiraColors.purple1, fontSize: 20)),
                          numeric: false,
                          tooltip: "Deposit Amount",
                        ),
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
                              onSortColum(columnIndex, ascending);
                            }),
                        DataColumn(
                          label: Text("From",
                              style: TextStyle(
                                  color: KiraColors.purple1, fontSize: 20)),
                          numeric: false,
                          tooltip: "From Address",
                        ),
                      ],
                      rows: transactions
                          .map(
                            (token) => DataRow(cells: [
                              DataCell(
                                Text(token.hash,
                                    style: TextStyle(
                                        color: KiraColors.black, fontSize: 15)),
                              ),
                              DataCell(
                                Text(token.token,
                                    style: TextStyle(
                                        color: KiraColors.black, fontSize: 15)),
                              ),
                              DataCell(
                                Text(token.status,
                                    style: TextStyle(
                                        color: KiraColors.black, fontSize: 15)),
                              ),
                              DataCell(
                                Text(token.depositAmount,
                                    style: TextStyle(
                                        color: KiraColors.black, fontSize: 15)),
                              ),
                              DataCell(
                                Text(token.timestamp,
                                    style: TextStyle(
                                        color: KiraColors.black, fontSize: 15)),
                              ),
                              DataCell(
                                Text(token.from,
                                    style: TextStyle(
                                        color: KiraColors.black, fontSize: 15)),
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
