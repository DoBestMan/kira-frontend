import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/models/block.dart';
import 'package:kira_auth/utils/colors.dart';

class BlocksTable extends StatefulWidget {
  final List<Block> blocks;
  final int expandedIndex;
  final Function onChangeLikes;
  final Function onTapRow;

  BlocksTable({
    Key key,
    this.blocks,
    this.expandedIndex,
    this.onChangeLikes,
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 2,
            child: Text("${block.rank + 1}.",
              textAlign: TextAlign.center,
              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
            )
          ),
          Expanded(
            flex: 9,
            child: Text(block.address,
              textAlign: TextAlign.center,
              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
            )
          ),
          Expanded(
            flex: 3,
            child: Text(block.moniker,
              textAlign: TextAlign.center,
              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)
            )
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(
                  color: block.getStatusColor().withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: InkWell(
                child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(Icons.circle, size: 12.0, color: block.getStatusColor()),
                ),
              ))
          ),
          Expanded(
            flex: 2,
            child: IconButton(
              icon: Icon(block.isFavorite ? Icons.favorite : Icons.favorite_border, color: KiraColors.blue1),
              color: block.isFavorite ? KiraColors.kYellowColor2 : KiraColors.white,
              onPressed: () => widget.onChangeLikes(block.rank))
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
                child: Text("Block Key",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(block.valkey, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Public Key",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(block.pubkey, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Website",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(block.checkUnknownWith("website"), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Social",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(block.checkUnknownWith("social"), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Identity",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Text(block.checkUnknownWith("identity"), style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children:[
              Expanded(
                flex: 1,
                child: Text("Commission",
                  textAlign: TextAlign.right,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(width: 20),
              Flexible(
                flex: 5,
                child: Container(
                  width: 200,
                  height: 30,
                  decoration: new BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: new Border.all(color: block.getCommissionColor().withOpacity(0.6), width: 1),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: Container(
                      margin: EdgeInsets.only(right: 194.0 - 194.0 * block.commission),
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: block.getCommissionColor()
                      )
                    )
                  )
                ),
              )
            ],
          ),
          SizedBox(height: 10),
        ]
      ));
  }
}
