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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(block.getHeightString(), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)),
          SizedBox(width: 10),

          // ClipRRect(
          //   borderRadius: BorderRadius.circular(15),
          //   child: SvgPicture.string(block.getProposerIcon(), fit: BoxFit.contain, width: 30, height: 30),
          // ),
          // SizedBox(width: 5),
          Text(block.Proposer(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)),

          SizedBox(width: 10),
          Text(block.txAmount.toString(),
              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16), textAlign: TextAlign.end),
          SizedBox(width: 10),
          Text(block.getTimeString(),
              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16), textAlign: TextAlign.end)
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
            margin: EdgeInsets.only(left: 100),
            padding: EdgeInsets.all(10),
            child: Column(children: [
              Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("Tx Hash",
                        style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    Text("Type",
                        style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    Text("Height",
                        style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end),
                    SizedBox(width: 10),
                    Text("Time",
                        style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.end),
                    SizedBox(width: 10),
                    Text("Status",
                        style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)
                  ])),
              ...widget.transactions
                  .map((transaction) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(transaction.hash,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)),
                          SizedBox(width: 10),
                          Row(
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
                          ),
                          SizedBox(width: 10),
                          Text(block.getHeightString(),
                              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
                              textAlign: TextAlign.end),
                          SizedBox(width: 10),
                          Text(block.getTimeString(),
                              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
                              textAlign: TextAlign.end),
                          SizedBox(width: 10),
                          Container(
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
                                  child: Icon(Icons.circle, size: 12.0, color: widget.transactions[0].getStatusColor()),
                                ),
                              ))
                        ],
                      ))
                  .toList()
            ]));
  }
}
