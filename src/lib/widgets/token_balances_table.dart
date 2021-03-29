import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/utils/colors.dart';

class TokenBalancesTable extends StatefulWidget {
  final List<Token> tokens;
  TokenBalancesTable({
    Key key,
    this.tokens,
  }) : super();

  @override
  _TokenBalancesTableState createState() => _TokenBalancesTableState();
}

class _TokenBalancesTableState extends State<TokenBalancesTable> {
  bool sort;

  @override
  void initState() {
    super.initState();
    sort = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        widget.tokens.sort((a, b) => a.assetName.compareTo(b.assetName));
      } else {
        widget.tokens.sort((a, b) => b.assetName.compareTo(a.assetName));
      }
    } else if (columnIndex == 2) {
      if (ascending) {
        widget.tokens.sort((a, b) => a.balance.compareTo(b.balance));
      } else {
        widget.tokens.sort((a, b) => b.balance.compareTo(a.balance));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 900),
          child: DataTable(
            showCheckboxColumn: false,
            columnSpacing: 20,
            sortAscending: sort,
            sortColumnIndex: 4,
            dataRowHeight: 70,
            columns: [
              DataColumn(
                  label: Flexible(
                    child: Text("Token Name", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
                  ),
                  numeric: false,
                  tooltip: "Token Name",
                  onSort: (columnIndex, ascending) {
                    if (mounted) {
                      setState(() {
                        sort = !sort;
                      });
                      onSortColum(columnIndex, sort);
                    }
                  }),
              DataColumn(
                label: Flexible(
                  child: Text("Ticker", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
                ),
                numeric: false,
                tooltip: "Ticker",
              ),
              DataColumn(
                  label: Flexible(
                    child: Text("Balance", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
                  ),
                  numeric: false,
                  tooltip: "Balance",
                  onSort: (columnIndex, ascending) {
                    if (mounted) {
                      setState(() {
                        sort = !sort;
                      });
                      onSortColum(columnIndex, sort);
                    }
                  }),
              DataColumn(
                label: Flexible(
                  child: Text("Denomination", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
                ),
                numeric: false,
                tooltip: "Denomination",
              ),
              DataColumn(
                label: Flexible(
                  child: Text("Decimals", style: TextStyle(color: KiraColors.kGrayColor, fontSize: 14)),
                ),
                numeric: false,
                tooltip: "Decimals",
              ),
            ],
            rows: widget.tokens
                .map(
                  (token) => DataRow(
                      color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                        // All rows will have the same selected color.
                        if (states.contains(MaterialState.selected)) return KiraColors.kYellowColor1.withOpacity(0.3);
                        // Even rows will have a grey color.
                        return KiraColors.white.withOpacity(0.05);
                      }),
                      cells: [
                        DataCell(Row(
                          children: [
                            SvgPicture.network(token.graphicalSymbol,
                                placeholderBuilder: (BuildContext context) => Container(
                                    padding: const EdgeInsets.all(30.0), child: const CircularProgressIndicator()),
                                width: 32,
                                height: 32),
                            SizedBox(width: 15),
                            Text(token.assetName,
                                style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
                          ],
                        )),
                        DataCell(
                          Text(token.ticker, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
                        ),
                        DataCell(
                          Text(token.balance.toString(),
                              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
                        ),
                        DataCell(
                          Text(token.denomination,
                              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
                        ),
                        DataCell(
                          Text(token.decimals.toString(),
                              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
                        ),
                      ]),
                )
                .toList(),
          ),
        ));
  }
}
