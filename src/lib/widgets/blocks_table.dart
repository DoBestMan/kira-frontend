import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/models/block.dart';
import 'package:kira_auth/utils/colors.dart';

class BlocksTable extends StatefulWidget {
  final List<Block> blocks;
  final int expandedIndex;
  final Function onTapRow;

  BlocksTable({
    Key key,
    this.blocks,
    this.expandedIndex,
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
          expansionCallback: (int index, bool isExpanded) => setState(() { widget.onTapRow(!isExpanded ? index : -1); }),
          children: widget.blocks.asMap().map((index, block) => MapEntry(index, ExpansionPanel(
            backgroundColor: KiraColors.transparent,
            headerBuilder: (BuildContext bctx, bool isExpanded) => addRowHeader(block, isExpanded),
            body: addRowBody(block),
            isExpanded: widget.expandedIndex == index,
            canTapOnHeader: true,
          ))).values.toList(),
        )
      ));
  }

  Widget addRowHeader(Block block, bool isExpanded) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(block.getTimeString(), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Text(block.appHash, overflow: TextOverflow.ellipsis, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(block.proposerAddress, overflow: TextOverflow.ellipsis, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Text(block.txAmount.toString(), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Text(block.getHeightString(), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16))
          )],
        ),
      );
  }

  Widget addRowBody(Block block) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Chain ID",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(block.chainId, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Consensus Hash",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(block.consensusHash, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Data Hash",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(block.dataHash, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Evidence Hash",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(block.evidenceHash, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Last Commit Hash",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(block.lastCommitHash, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
        ]
      ));
  }
}
