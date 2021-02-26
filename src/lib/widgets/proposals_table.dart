import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/models/proposal.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/export.dart';

class ProposalsTable extends StatefulWidget {
  final List<Proposal> proposals;
  final int expandedIndex;
  final Function onTapRow;

  ProposalsTable({
    Key key,
    this.proposals,
    this.expandedIndex,
    this.onTapRow,
  }) : super();

  @override
  _ProposalsTableState createState() => _ProposalsTableState();
}

class _ProposalsTableState extends State<ProposalsTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            child: ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) => setState(() {
                widget.onTapRow(!isExpanded ? index : -1);
              }),
              children: widget.proposals
                  .asMap()
                  .map((index, proposal) => MapEntry(
                  index,
                  ExpansionPanel(
                    backgroundColor: KiraColors.transparent,
                    headerBuilder: (BuildContext bctx, bool isExpanded) => addRowHeader(proposal, isExpanded),
                    body: addRowBody(proposal),
                    isExpanded: widget.expandedIndex == index,
                    canTapOnHeader: true,
                  )))
                  .values
                  .toList(),
            )));
  }

  Widget addRowHeader(Proposal proposal, bool isExpanded) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              flex: ResponsiveWidget.isSmallScreen(context) ? 3 : 2,
              child: Text(
                "${proposal.rank + 1}.",
                textAlign: TextAlign.center,
                style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
              )
          ),
          Expanded(
              flex: ResponsiveWidget.isSmallScreen(context) ? 4 : 9,
              child: Align(
                  child: InkWell(
                      onTap: () {
                        copyText(proposal.address);
                        showToast("Proposal address copied");
                      },
                      child: Text(
                        proposal.getReducedAddress,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16),
                      )
                  )
              )
          ),
          Expanded(
              flex: 3,
              child: Align(
                  child: InkWell(
                    onTap: () {
                      copyText(proposal.moniker);
                      showToast("Proposal moniker copied");
                    },
                    child: Text(
                        proposal.moniker,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)
                    ),
                  )
              )
          ),
          Expanded(
              flex: 2,
              child: Container(
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    border: new Border.all(
                      color: proposal.getStatusColor().withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(Icons.circle, size: 12.0, color: proposal.getStatusColor()),
                    ),
                  ))
          ),
        ],
      ),
    );
  }

  Widget addRowBody(Proposal proposal) {
    final fieldWidth = ResponsiveWidget.isSmallScreen(context) ? 100.0 : 150.0;
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text(
                      "Proposal Key",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ),
              SizedBox(width: 20),
              Flexible(child: Text(
                  proposal.valkey,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text(
                      "Public Key",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ),
              SizedBox(width: 20),
              Flexible(child: Text(
                  proposal.pubkey,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text(
                      "Website",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ),
              SizedBox(width: 20),
              Text(proposal.checkUnknownWith("website"), overflow: TextOverflow.ellipsis, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text(
                      "Social",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ),
              SizedBox(width: 20),
              Text(proposal.checkUnknownWith("social"), overflow: TextOverflow.ellipsis, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text(
                      "Identity",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ),
              SizedBox(width: 20),
              Text(proposal.checkUnknownWith("identity"), overflow: TextOverflow.ellipsis, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text(
                      "Commission",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)
                  )
              ),
              SizedBox(width: 20),
              Container(
                  width: 200,
                  height: 30,
                  decoration: new BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: new Border.all(color: proposal.getCommissionColor().withOpacity(0.6), width: 1),
                  ),
                  child: Padding(padding: EdgeInsets.all(3), child: Container(margin: EdgeInsets.only(right: 194.0 - 194.0 * proposal.commission), height: 24, decoration: BoxDecoration(shape: BoxShape.rectangle, color: proposal.getCommissionColor())))),
            ],
          ),
          SizedBox(height: 10),
        ]));
  }
}
