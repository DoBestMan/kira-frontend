import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/services/token_service.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/blocs/export.dart';

class TokenBalancesTable extends StatefulWidget {
  const TokenBalancesTable({
    Key key,
  }) : super(key: key);

  @override
  _TokenBalancesTableState createState() => _TokenBalancesTableState();
}

class _TokenBalancesTableState extends State<TokenBalancesTable> {
  TokenService tokenService = TokenService();
  Account currentAccount;
  List<Token> tokens = List();
  bool sort;

  @override
  void initState() {
    super.initState();
    sort = false;
    getTokens();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getTokens() async {
    Account currentAccount;
    if (BlocProvider.of<AccountBloc>(context).state.currentAccount != null) {
      currentAccount =
          BlocProvider.of<AccountBloc>(context).state.currentAccount;
    }
    if (currentAccount != null)
      await tokenService.getTokens(currentAccount.bech32Address);
    // await tokenService.faucet(currentAccount.bech32Address, 'validatortoken');
    if (mounted) {
      setState(() {
        currentAccount = currentAccount;
        tokens = tokenService.tokens;
      });
    }
  }

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        tokens.sort((a, b) => a.assetName.compareTo(b.assetName));
      } else {
        tokens.sort((a, b) => b.assetName.compareTo(a.assetName));
      }
    } else if (columnIndex == 2) {
      if (ascending) {
        tokens.sort((a, b) => a.balance.compareTo(b.balance));
      } else {
        tokens.sort((a, b) => b.balance.compareTo(a.balance));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columnSpacing: 80,
        sortAscending: sort,
        sortColumnIndex: 0,
        columns: [
          DataColumn(
              label: Flexible(
                child: Text("Token Name",
                    style: TextStyle(color: KiraColors.purple1, fontSize: 18)),
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
              child: Text("Ticker",
                  style: TextStyle(color: KiraColors.purple1, fontSize: 18)),
            ),
            numeric: false,
            tooltip: "Ticker",
          ),
          DataColumn(
              label: Flexible(
                child: Text("Balance",
                    style: TextStyle(color: KiraColors.purple1, fontSize: 18)),
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
              child: Text("Denomination",
                  style: TextStyle(color: KiraColors.purple1, fontSize: 18)),
            ),
            numeric: false,
            tooltip: "Denomination",
          ),
          DataColumn(
            label: Flexible(
              child: Text("Decimals",
                  style: TextStyle(color: KiraColors.purple1, fontSize: 18)),
            ),
            numeric: false,
            tooltip: "Decimals",
          ),
          // DataColumn(
          //   label: Flexible(
          //     child: Text("Faucet",
          //         style: TextStyle(color: KiraColors.purple1, fontSize: 18)),
          //   ),
          //   numeric: false,
          //   tooltip: "Faucet",
          // )
        ],
        rows: tokens
            .map(
              (token) => DataRow(cells: [
                DataCell(
                  Row(children: [
                    Image.network(token.graphicalSymbol, width: 25, height: 25),
                    SizedBox(width: 15),
                    Text(token.assetName,
                        style: TextStyle(
                            color: KiraColors.black.withOpacity(0.8),
                            fontSize: 16)),
                  ]),
                ),
                DataCell(
                  Text(token.ticker,
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 16)),
                ),
                DataCell(
                  Text(token.balance.toString(),
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 16)),
                ),
                DataCell(
                  Text(token.denomination,
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 16)),
                ),
                DataCell(
                  Text(token.decimals.toString(),
                      style: TextStyle(
                          color: KiraColors.black.withOpacity(0.8),
                          fontSize: 16)),
                ),
                // DataCell(CustomButton(
                //   key: Key('faucet'),
                //   text: "Faucet",
                //   height: 30.0,
                //   fontSize: 15,
                //   onPressed: () async {},
                //   backgroundColor: KiraColors.green2,
                // ))
              ]),
            )
            .toList(),
      ),
    );
  }
}
