import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/utils/colors.dart';

class BlocksTable extends StatefulWidget {
  final List<Block> blocks;
  final List<Transaction> transactions;
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
          expansionCallback: (int index, bool isExpanded) => setState(() { widget.onTapRow(!isExpanded ? widget.blocks[index].height : -1); }),
          children: widget.blocks.map((block) => ExpansionPanel(
            backgroundColor: KiraColors.transparent,
            headerBuilder: (BuildContext bctx, bool isExpanded) => addRowHeader(block, isExpanded),
            body: addRowBody(block),
            isExpanded: widget.expandedHeight == block.height,
            canTapOnHeader: true,
          )).toList(),
        )
      ));
  }

  Widget addRowHeader(Block block, bool isExpanded) {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Text(block.getHeightString(), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(block.getProposerString(), overflow: TextOverflow.ellipsis, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Text(block.txAmount.toString(), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16), textAlign: TextAlign.end)
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Text(block.getTimeString(), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16), textAlign: TextAlign.end)
          )],
        ),
      );
  }

  Widget addRowBody(Block block) {
    return widget.transactions.isEmpty ? Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Text("No transactions in this block",
        style: TextStyle(color: KiraColors.white, fontSize: 16, fontWeight: FontWeight.bold)
      )
    ) : Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Transaction Hash",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(widget.transactions[0].hash, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Sender",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(widget.transactions[0].sender, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Recipient",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(widget.transactions[0].recipient, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Amount",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(widget.transactions[0].amount, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Status",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Container(
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      border: new Border.all(
                        color: widget.transactions[0].getStatusColor().withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(Icons.circle, size: 12.0, color: widget.transactions[0].getStatusColor()),
                      ),
                    ))
              )
            ],
          ),
          SizedBox(height: 10),
        ]
      ));
  }
}
