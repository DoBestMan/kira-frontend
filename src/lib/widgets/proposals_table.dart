import 'dart:ui';
import 'package:pie_chart/pie_chart.dart';
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
  int voteOption;

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
            child: Text(proposal.content.getName(),
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
    final voteOptions = proposal.availableVoteOptions().map((e) => VoteOption.values.indexOf(e)).toList();
    var allColors = [KiraColors.kGrayColor, KiraColors.green3, KiraColors.orange1, KiraColors.danger, KiraColors.danger];
    var colorList = allColors.where((element) {
      final colorIndex = allColors.indexOf(element);
      return proposal.voteResults.keys.contains(Strings.voteTitles[colorIndex]);
    }).toList();
    final hasVotes = colorList.isNotEmpty;

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
                          child: Text("Voters",
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
                          child: Text("Description",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold))),
                      SizedBox(width: 20),
                      Flexible(
                          child: Text(proposal.description,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))),
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
              (!hasVotes || !ResponsiveWidget.isLargeScreen(context)) ? Container() :
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: PieChart(
                  dataMap: proposal.voteResults,
                  animationDuration: Duration(milliseconds: 800),
                  chartLegendSpacing: 20,
                  chartRadius: 200,
                  colorList: colorList,
                  initialAngleInDegree: 0,
                  chartType: ChartType.disc,
                  legendOptions: LegendOptions(
                    showLegends: true,
                    showLegendsInRow: false,
                    legendShape: BoxShape.circle,
                    legendTextStyle: TextStyle(color: KiraColors.white),
                  ),
                  chartValuesOptions: ChartValuesOptions(
                      showChartValueBackground: false,
                      showChartValuesInPercentage: true,
                      decimalPlaces: 1,
                      chartValueStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)
                  ),
                ),
              ),
              !proposal.isVoteable ? Container() :
              Expanded(
                  flex: 1,
                  child: Column(
                      children: <Widget>[
                        Text(hasVotes ? Strings.voteUpdate : Strings.voteProposal,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: KiraColors.white, fontSize: 16)),
                        SizedBox(height: 20),
                        Container(
                            width: 200,
                            color: KiraColors.kPrimaryColor,
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<int>(
                                  dropdownColor: KiraColors.kPurpleColor,
                                  value: voteOption,
                                  icon: Icon(Icons.arrow_drop_down, color: KiraColors.white),
                                  iconSize: 32,
                                  isExpanded: true,
                                  hint: Text(Strings.voteHint,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: KiraColors.white, fontSize: 14)),
                                  underline: SizedBox(),
                                  onChanged: (int option) {
                                    setState(() {
                                      voteOption = option;
                                    });
                                  },
                                  items: voteOptions.map<DropdownMenuItem<int>>((int option) {
                                    return DropdownMenuItem<int>(
                                      value: option,
                                      child: Container(
                                          height: 25,
                                          alignment: Alignment.topCenter,
                                          child: Text(Strings.voteTitles[option],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: KiraColors.white, fontSize: 14))),
                                    );
                                  }).toList()),
                            )
                        ),
                        SizedBox(height: 20),
                        CustomButton(
                            text: hasVotes ? Strings.update : Strings.vote,
                            width: 100,
                            height: 40,
                            style: 1,
                            onPressed: () {
                              if (voteOption < 1) return;
                              widget.onTapVote(proposal.proposalId, voteOption);
                            }),
                      ])
              )
            ])
    );
  }
}
