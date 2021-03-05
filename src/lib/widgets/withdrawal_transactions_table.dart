import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/utils/export.dart';

class WithdrawalTransactionsTable extends StatefulWidget {
  final List<Transaction> transactions;
  WithdrawalTransactionsTable({
    Key key,
    this.transactions,
  }) : super();

  @override
  _WithdrawalTransactionsTableState createState() => _WithdrawalTransactionsTableState();
}

class _WithdrawalTransactionsTableState extends State<WithdrawalTransactionsTable> {
  bool sort;
  Timer timer;
  int copiedIndex;

  @override
  void initState() {
    super.initState();

    sort = false;
    copiedIndex = -1;
  }

  void onSortColum(int columnIndex, bool ascending) {
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
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 900),
          child: DataTable(
            showCheckboxColumn: false,
            columnSpacing: 40,
            sortAscending: sort,
            sortColumnIndex: 4,
            columns: [
              DataColumn(
                label: Flexible(
                  child: Text("Transaction Hash", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
                ),
                numeric: false,
                tooltip: "Transaction Hash",
              ),
              DataColumn(
                label: Flexible(
                  child: Text("Token", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
                ),
                numeric: false,
                tooltip: "Asset Name",
              ),
              DataColumn(
                label: Flexible(
                  child: Text("Amount", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
                ),
                numeric: false,
                tooltip: "Withdrawal Amount",
              ),
              DataColumn(
                label: Flexible(
                  child: Text("Status", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
                ),
                numeric: false,
                tooltip: "Status",
              ),
              DataColumn(
                  label: Flexible(
                    child: Text("Timestamp", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
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
                  child: Text("Recipient", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
                ),
                numeric: false,
                tooltip: "Recipient Address",
              ),
            ],
            rows: widget.transactions
                .asMap()
                .entries
                .map((entry) {
                  var index = entry.key;
                  var token = entry.value;
                  String tokenHash = token.hash.toLowerCase();
                  return DataRow(
                      color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                        // All rows will have the same selected color.
                        if (states.contains(MaterialState.selected)) return KiraColors.kYellowColor1.withOpacity(0.3);
                        // Even rows will have a grey color.
                        return KiraColors.white.withOpacity(0.05);
                      }),
                      cells: [
                        DataCell(InkWell(
                          onTap: () {
                            copyText(tokenHash);
                            showToast(Strings.txHashCopied);
                          },
                          child: Container(
                            child: Row(
                              children: [
                                // Flexible(
                                Container(
                                  width: 200,
                                  child: Text(tokenHash.replaceRange(10, tokenHash.length - 7, '...'),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
                                ),
                                // ),
                                if (token.isNew == true)
                                  Container(
                                    alignment: AlignmentDirectional(0, 0),
                                    width: 20,
                                    margin: EdgeInsets.only(left: 10, right: 10),
                                    child: Icon(Icons.fiber_new, color: KiraColors.blue1),
                                  ),
                              ],
                            ),
                            width: 250,
                          ),
                        )),
                        DataCell(
                          Text(token.token, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
                        ),
                        DataCell(
                          Text(token.amount, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
                        ),
                        DataCell(
                          Text(token.status, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
                        ),
                        DataCell(
                          Text(token.timestamp,
                              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
                        ),
                        DataCell(InkWell(
                          onTap: () {
                            copyText(token.recipient);
                            showToast(Strings.recipientAddressCopied);
                          },
                          child: // Flexible(
                              Text(token.recipient.replaceRange(10, token.recipient.length - 7, '...'),
                                  softWrap: true,
                                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
                        )),
                      ]);
                })
                .toSet()
                .toList(),
          ),
        ));
  }
}
