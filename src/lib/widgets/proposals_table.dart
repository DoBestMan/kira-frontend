import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kira_auth/models/proposal.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/export.dart';

import 'custom_button.dart';

class ProposalsTable extends StatefulWidget {
  final List<Proposal> proposals;
  final List<int> voteable;
  final int expandedIndex;
  final Function onTapRow;
  final Function onTapVote;

  ProposalsTable({
    Key key,
    this.proposals,
    this.voteable,
    this.expandedIndex,
    this.onTapRow,
    this.onTapVote,
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
      expansionCallback: (int index, bool isExpanded) => widget.onTapRow(!isExpanded ? index : -1),
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
            flex: 1,
            child: Text(proposal.proposalId,
                textAlign: TextAlign.center, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)),
          ),
          Expanded(
              flex: 1,
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
                  ))),
          Expanded(
            flex: 2,
            child: Text(proposal.submitTime.toString(),
                style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)),
          ),
          Expanded(
            flex: 2,
            child: Text(proposal.votingEndTime.toString(),
                style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)),
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
                  child: Text("Content",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold))),
              SizedBox(width: 20),
              Flexible(
                  child: Text(proposal.content.messages.join(", "),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text("Expiration Time",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold))),
              SizedBox(width: 20),
              Flexible(
                  child: Text(proposal.enactmentEndTime.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                  width: fieldWidth,
                  child: Text("Status",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold))),
              SizedBox(width: 20),
              Text(proposal.getStatusString,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
            ],
          ),
          SizedBox(height: 10),
          proposal.voteOptions.isNotEmpty
              ? CustomButton(
                  key: Key(Strings.vote),
                  text: Strings.vote,
                  width: 150,
                  height: 50,
                  style: 1,
                  onPressed: () {
                    widget.onTapVote(proposal.proposalId);
                  })
              : Container(width: 0, height: 0),
        ]));
  }
}
