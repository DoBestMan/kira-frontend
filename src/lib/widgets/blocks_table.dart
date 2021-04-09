import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/export.dart';

class BlocksTable extends StatefulWidget {
  final List<Block> blocks;
  final List<BlockTransaction> transactions;
  final int expandedHeight;
  final Function onTapRow;

  BlocksTable({
    Key key,
    this.blocks,
    this.transactions,
    this.expandedHeight,
    this.onTapRow,
  }) : super();

  @override
  _BlocksTableState createState() => _BlocksTableState();
}

class _BlocksTableState extends State<BlocksTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            child: ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) => setState(() {
                widget.onTapRow(!isExpanded ? widget.blocks[index].height : -1);
              }),
              children: widget.blocks
                  .map((block) => ExpansionPanel(
                backgroundColor: KiraColors.transparent,
                headerBuilder: (BuildContext bctx, bool isExpanded) => addRowHeader(block, isExpanded),
                body: addRowBody(block),
                isExpanded: widget.expandedHeight == block.height,
                canTapOnHeader: true,
              ))
                  .toList(),
            )));
  }

  Widget addRowHeader(Block block, bool isExpanded) {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(block.getHeightString(),
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))),
          SizedBox(width: 10),
          Expanded(
              flex: 2,
              child: Row(children: [
                Container(
                    padding: EdgeInsets.all(5),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: new Border.all(
                        color: KiraColors.kPurpleColor,
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Container())),
                SizedBox(width: 5),
                Text(block.getProposer,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
              ])),
          SizedBox(width: 10),
          Expanded(
              flex: 1,
              child: Text(block.txAmount.toString(),
                  textAlign: TextAlign.end, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))),
          SizedBox(width: 10),
          Expanded(
              flex: 1,
              child: Text(block.getTimeString(),
                  textAlign: TextAlign.end, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)))
        ],
      ),
    );
  }

  Widget addRowBody(Block block) {
    return widget.transactions.isEmpty
        ? Container(
        margin: EdgeInsets.only(top: 10, bottom: 20),
        child: Text("No transactions in this block",
            style: TextStyle(color: KiraColors.white, fontSize: 16, fontWeight: FontWeight.bold)))
        : Container(
        margin: EdgeInsets.only(left: ResponsiveWidget.isSmallScreen(context) ? 30 : 100),
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Row(children: [
                Expanded(
                    flex: 1,
                    child: Text("Tx Hash",
                        style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold))),
                SizedBox(width: 10),
                Expanded(
                    flex: ResponsiveWidget.isSmallScreen(context) ? 2 : 4,
                    child: Text("Type",
                        style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold))),
                SizedBox(width: 10),
                Expanded(
                    flex: 1,
                    child: Text("Height",
                        style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end)),
                SizedBox(width: 10),
                Expanded(
                    flex: 1,
                    child: Text("Time",
                        style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end)),
                SizedBox(width: 10),
                Expanded(
                    flex: 1,
                    child: Text("Status",
                        style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center))
              ])),
          ...widget.transactions
              .map((transaction) => Row(children: [
            Expanded(
                flex: 1,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                        onTap: () {
                          copyText(transaction.getHash);
                          showToast(Strings.txHashCopied);
                        },
                        child: Text(transaction.getReducedHash,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))))),
            SizedBox(width: 10),
            Expanded(
                flex: ResponsiveWidget.isSmallScreen(context) ? 2 : 4,
                child: Row(
                  children: transaction
                      .getTypes()
                      .map((type) => Container(
                      padding: EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 4),
                      child: Text(type,
                          style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)),
                      decoration: BoxDecoration(
                          color: KiraColors.purple1.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4))))
                      .toList(),
                )),
            SizedBox(width: 10),
            Expanded(
                flex: 1,
                child: Text(transaction.getHeightString(),
                    style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
                    textAlign: TextAlign.end)),
            SizedBox(width: 10),
            Expanded(
                flex: 1,
                child: Text(transaction.getTimeString(),
                    style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
                    textAlign: TextAlign.end)),
            SizedBox(width: 10),
            Expanded(
                flex: 1,
                child: Container(
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      border: new Border.all(
                        color: transaction.getStatusColor().withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(Icons.circle, size: 12.0, color: transaction.getStatusColor()),
                      ),
                    )))
          ]))
              .toList()
        ]));
  }
}
