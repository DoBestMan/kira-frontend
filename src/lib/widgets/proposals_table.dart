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
  final List<String> voteTitles = ["Unspecified", "Yes", "Abstain", "No", "No with Veto"];

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
                    backgroundColor: proposal.isVoteable ? KiraColors.white.withOpacity(0.2) : KiraColors.transparent,
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
            flex: 2,
            child: Text(proposal.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)),
          ),
          Expanded(
            flex: 1,
            child: Text(proposal.getStatusString(),
                textAlign: TextAlign.center, style: TextStyle(color: proposal.getStatusColor(), fontSize: 16)),
          ),
          Expanded(
            flex: 1,
            child: Text(proposal.getTimeString(),
                style: TextStyle(color: proposal.getTimeColor(), fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget addRowBody(Proposal proposal) {
    final fieldWidth = ResponsiveWidget.isSmallScreen(context) ? 100.0 : 150.0;
    final List<String> voteTitles = ["Unspecified", "Yes", "Abstain", "No", "No with Veto"];
    final voteOptions = proposal.availableVoteOptions().map((e) => VoteOption.values.indexOf(e)).toList();

    return Container(
        padding: EdgeInsets.all(10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(children: [
                  Row(
                    children: [
                      Container(
                          width: fieldWidth,
                          child: Text("Number of Actors",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold))),
                      SizedBox(width: 20),
                      Text("${proposal.voteability.count}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
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
                      Text(proposal.getStatusString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 10),
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
                          child: Text(proposal.getContent,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))),
                    ],
                  ),
                ]),
              ),
              !proposal.isVoteable ? Container() :
              Expanded(
                  flex: 1,
                  child: Container(
                      child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3,
                          controller: new ScrollController(keepScrollOffset: false),
                          shrinkWrap: true,
                          children: voteOptions.map((e) =>
                              CustomButton(
                                  text: voteTitles[e],
                                  width: 150,
                                  height: 50,
                                  style: 1,
                                  onPressed: () {
                                    widget.onTapVote(proposal.proposalId, e);
                                  }),
                          ).toList()
                      )
                  ))
            ])
    );
  }
}
