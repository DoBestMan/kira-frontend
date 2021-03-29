import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/services/export.dart';

class TokenTable extends StatefulWidget {
  final List<Token> tokens;
  final int expandedIndex;
  final Function onTapRow;
  final String address;

  TokenTable({
    Key key,
    this.tokens,
    this.expandedIndex,
    this.onTapRow,
    this.address,
  }) : super();

  @override
  TokenTableState createState() => TokenTableState();
}

class TokenTableState extends State<TokenTable> {
  TokenService tokenService = TokenService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            child: ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) => setState(() {
        widget.onTapRow(!isExpanded ? index : -1);
      }),
      children: widget.tokens
          .asMap()
          .map((index, token) => MapEntry(
              index,
              ExpansionPanel(
                backgroundColor: KiraColors.transparent,
                headerBuilder: (BuildContext bctx, bool isExpanded) => addRowHeader(token, isExpanded),
                body: addRowBody(token),
                isExpanded: widget.expandedIndex == index,
                canTapOnHeader: true,
              )))
          .values
          .toList(),
    )));
  }

  Widget addRowHeader(Token token, bool isExpanded) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(width: 50),
          Expanded(
              flex: ResponsiveWidget.isSmallScreen(context) ? 3 : 2,
              child: Row(
                children: [
                  SvgPicture.network(token.graphicalSymbol,
                      placeholderBuilder: (BuildContext context) =>
                          Container(padding: const EdgeInsets.all(30.0), child: const CircularProgressIndicator()),
                      width: 32,
                      height: 32),
                  SizedBox(width: 15),
                  Text(
                    token.assetName,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
                  )
                ],
              )),
          Expanded(
              flex: 2,
              child: Align(
                  child: InkWell(
                      onTap: () {
                        copyText(token.balance.toString());
                        showToast("Token balance copied");
                      },
                      child: Text(
                        token.balance.toString() + " " + token.ticker,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
                      )))),
        ],
      ),
    );
  }

  Widget addRowBody(Token token) {
    final fieldWidth = ResponsiveWidget.isSmallScreen(context) ? 130.0 : 200.0;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 50),
        child: Column(children: [
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text("Token Name : ",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold))),
              SizedBox(width: 20),
              Flexible(
                  child: Text(token.assetName,
                      overflow: TextOverflow.fade,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text("Ticker : ",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold))),
              SizedBox(width: 20),
              Flexible(
                  child: Text(token.ticker,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text("Balance : ",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold))),
              SizedBox(width: 20),
              Text(token.balance.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text("Denomination : ",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold))),
              SizedBox(width: 20),
              Text(token.denomination,
                  overflow: TextOverflow.fade,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text("Decimals : ",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold))),
              SizedBox(width: 20),
              Text(token.decimals.toString(),
                  overflow: TextOverflow.fade,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              CustomButton(
                key: Key(Strings.faucet),
                text: Strings.faucet,
                width: 90,
                height: 40,
                style: 1,
                fontSize: 15,
                onPressed: () async {
                  if (widget.address.length > 0) {
                    String result = await tokenService.faucet(widget.address, token.denomination);
                    showToast(result);
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 20),
        ]));
  }
}
