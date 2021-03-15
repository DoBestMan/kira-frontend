import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/models/export.dart';

class ProposalsScreen extends StatefulWidget {
  @override
  _ProposalsScreenState createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends State<ProposalsScreen> {
  ProposalService proposalService = ProposalService();
  StatusService statusService = StatusService();
  List<Proposal> proposals = [];
  List<Proposal> filteredProposals = [];
  List<int> voteable = [0, 2];
  final List<String> voteTitles = ["Please select", "Unspecified", "Yes", "Abstain", "No", "No with Veto"];
  int voteType = 0;

  int expandedIndex = -1;
  int sortIndex = 0;
  bool isAscending = true;
  bool isNetworkHealthy = false;

  @override
  void initState() {
    super.initState();
    getNodeStatus();
    getProposals();
  }

  void getProposals() async {
    if (mounted) {
      var currentAccount;
      if (BlocProvider.of<AccountBloc>(context).state.currentAccount != null) {
        currentAccount = BlocProvider.of<AccountBloc>(context).state.currentAccount;
      }
      await proposalService.getProposals(account: currentAccount != null ? currentAccount.bech32Address : '');
      setState(() {
        voteType = 0;
        proposals.addAll(proposalService.proposals);
        filteredProposals.addAll(proposalService.proposals);
      });
    }
  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        if (statusService.nodeInfo.network.isNotEmpty) {
          DateTime latestBlockTime = DateTime.tryParse(statusService.syncInfo.latestBlockTime);
          isNetworkHealthy = DateTime.now().difference(latestBlockTime).inMinutes > 1 ? false : true;
        } else {
          isNetworkHealthy = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    checkPasswordExpired().then((success) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
        body: BlocConsumer<AccountBloc, AccountState>(
            listener: (context, state) {},
            builder: (context, state) {
              return HeaderWrapper(
                  isNetworkHealthy: isNetworkHealthy,
                  childWidget: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 50, bottom: 50),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            addHeader(),
                            addTableHeader(),
                            (proposals.isNotEmpty && filteredProposals.isEmpty)
                                ? Container(
                                    margin: EdgeInsets.only(top: 20, left: 20),
                                    child: Text("No matching proposals",
                                        style: TextStyle(
                                            color: KiraColors.white, fontSize: 18, fontWeight: FontWeight.bold)))
                                : addProposalsTable(),
                          ],
                        ),
                      )));
            }));
  }

  Widget addHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: 40),
      child: ResponsiveWidget.isLargeScreen(context)
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                addHeaderTitle(),
                addSearchInput(),
              ],
            )
          : Column(
              children: <Widget>[
                addHeaderTitle(),
                addSearchInput(),
              ],
            ),
    );
  }

  Widget addHeaderTitle() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Text(
          Strings.proposals,
          textAlign: TextAlign.left,
          style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
        ));
  }

  Widget addSearchInput() {
    return Container(
      width: 500,
      child: AppTextField(
        hintText: Strings.proposalQuery,
        labelText: Strings.search,
        textInputAction: TextInputAction.search,
        maxLines: 1,
        autocorrect: false,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.left,
        onChanged: (String newText) {
          this.setState(() {
            filteredProposals = proposals.where((x) => x.proposalId.contains(newText)).toList();
            expandedIndex = -1;
          });
        },
        padding: EdgeInsets.only(bottom: 15),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
          color: KiraColors.white,
          fontFamily: 'NunitoSans',
        ),
        topMargin: 10,
      ),
    );
  }

  Widget addTableHeader() {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(right: ResponsiveWidget.isSmallScreen(context) ? 40 : 65, bottom: 20),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: InkWell(
                  onTap: () => this.setState(() {
                        if (sortIndex == 0)
                          isAscending = !isAscending;
                        else {
                          sortIndex = 0;
                          isAscending = true;
                        }
                        expandedIndex = -1;
                        refreshTableSort();
                      }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: sortIndex != 0
                        ? [
                            Text("ID",
                                style:
                                    TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          ]
                        : [
                            Text("ID",
                                style:
                                    TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 5),
                            Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                          ],
                  ))),
          Expanded(
              flex: 1,
              child: InkWell(
                  onTap: () => this.setState(() {
                        if (sortIndex == 1)
                          isAscending = !isAscending;
                        else {
                          sortIndex = 1;
                          isAscending = true;
                        }
                        expandedIndex = -1;
                        refreshTableSort();
                      }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: sortIndex != 1
                        ? [
                            Text("Status",
                                style:
                                    TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          ]
                        : [
                            Text("Status",
                                style:
                                    TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 5),
                            Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                          ],
                  ))),
          Expanded(
              flex: 2,
              child: InkWell(
                  onTap: () => this.setState(() {
                        if (sortIndex == 2)
                          isAscending = !isAscending;
                        else {
                          sortIndex = 2;
                          isAscending = true;
                        }
                        expandedIndex = -1;
                        refreshTableSort();
                      }),
                  child: Row(
                      children: sortIndex != 2
                          ? [
                              Text("Voting Start Time",
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            ]
                          : [
                              Text("Voting Start Time",
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(width: 5),
                              Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                            ]))),
          Expanded(
              flex: 2,
              child: InkWell(
                  onTap: () => this.setState(() {
                        if (sortIndex == 3)
                          isAscending = !isAscending;
                        else {
                          sortIndex = 3;
                          isAscending = true;
                        }
                        expandedIndex = -1;
                        refreshTableSort();
                      }),
                  child: Row(
                      children: sortIndex != 3
                          ? [
                              Text("Voting End Time",
                                  maxLines: 3,
                                  style: TextStyle(
                                      color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            ]
                          : [
                              Text("Voting End Time",
                                  maxLines: 3,
                                  style: TextStyle(
                                      color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(width: 5),
                              Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, color: KiraColors.white),
                            ]))),
        ],
      ),
    );
  }

  Widget addProposalsTable() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProposalsTable(
              proposals: filteredProposals,
              voteable: voteable,
              expandedIndex: expandedIndex,
              onTapRow: (index) => this.setState(() {
                expandedIndex = index;
              }),
              onTapVote: (id) => vote(id),
            ),
          ],
        ));
  }

  vote(String id) {
    var voteOptions = proposals.firstWhere((proposal) => proposal.proposalId == id).voteOptions;
    var options = voteOptions.map((e) => VoteType.values.indexOf(e) + 1).toList();
    options.insert(0, 0);
    Widget noButton = TextButton(
      child: Text(
        Strings.cancel,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    Widget yesButton = TextButton(
      child: Text(
        Strings.vote,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      onPressed: () {
        if (voteType == 0) {
          return;
        }
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          contentWidgets: [
            Text(
              Strings.voteProposal,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: KiraColors.kPurpleColor, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              Strings.proposalDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 15,
            ),
            ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<int>(
                  dropdownColor: KiraColors.white,
                  value: voteType,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 32,
                  underline: SizedBox(),
                  onChanged: (int type) {
                    setState(() {
                      voteType = type;
                    });
                  },
                  items: options.map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Container(
                          height: 25,
                          alignment: Alignment.topCenter,
                          child: Text(voteTitles[value],
                              style: TextStyle(
                                  color: KiraColors.kLightPurpleColor, fontSize: 18, fontWeight: FontWeight.w400))),
                    );
                  }).toList()),
            ),
            SizedBox(height: 22),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[yesButton, noButton]),
          ],
        );
      },
    );
  }

  refreshTableSort() {
    this.setState(() {
      if (sortIndex == 0) {
        filteredProposals
            .sort((a, b) => isAscending ? a.proposalId.compareTo(b.proposalId) : b.proposalId.compareTo(a.proposalId));
      } else if (sortIndex == 1) {
        filteredProposals.sort((a, b) => isAscending ? a.result.compareTo(b.result) : b.result.compareTo(a.result));
      } else if (sortIndex == 2) {
        filteredProposals
            .sort((a, b) => isAscending ? a.submitTime.compareTo(b.submitTime) : b.submitTime.compareTo(a.submitTime));
      } else if (sortIndex == 3) {
        filteredProposals.sort((a, b) =>
            isAscending ? a.votingEndTime.compareTo(b.votingEndTime) : b.votingEndTime.compareTo(a.votingEndTime));
      }
    });
  }
}
