import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kira_auth/helpers/export.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/models/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Timer timer;
  String pendingTxHash;
  String lastProposalId;
  int lastOption;
  String lastAccountNumber;
  String lastSequence;
  String query = "";
  bool initialFetched = false;

  Account currentAccount;
  String feeAmount;
  Token feeToken;
  String expandedId;
  bool isNetworkHealthy = false;
  StreamController proposalController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();

    getNodeStatus();
    if (mounted) {
      if (BlocProvider.of<AccountBloc>(context).state.currentAccount != null) {
        currentAccount = BlocProvider.of<AccountBloc>(context).state.currentAccount;
      }
      if (BlocProvider.of<TokenBloc>(context).state.feeToken != null) {
        feeToken = BlocProvider.of<TokenBloc>(context).state.feeToken;
      }
      getCachedFeeAmount();
      if (feeToken == null) {
        getFeeToken();
      }
    }

    getProposals(false);
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      getProposals(true);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void getProposals(bool loadNew) async {
    await proposalService.getProposals(loadNew, account: currentAccount != null ? currentAccount.bech32Address : '');
    if (proposalService.totalCount > proposalService.proposals.length)
      getProposals(false);
    setState(() {
      initialFetched = true;
      proposals.clear();
      proposals.addAll(proposalService.proposals);
      filteredProposals.clear();
      filteredProposals.addAll(query.isEmpty ? proposals : proposals.where((x) => x.proposalId.contains(query) ||
          x.content.getName().toLowerCase().contains(query) || x.getStatusString().toLowerCase().contains(query)));
      proposalController.add(null);
    });
  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        if (statusService.nodeInfo != null && statusService.nodeInfo.network.isNotEmpty) {
          isNetworkHealthy = statusService.isNetworkHealthy;
          BlocProvider.of<NetworkBloc>(context)
              .add(SetNetworkInfo(statusService.nodeInfo.network, statusService.rpcUrl));
        } else {
          isNetworkHealthy = false;
        }
      });
    }
  }

  void getCachedFeeAmount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      int cfeeAmount = prefs.getInt('feeAmount');
      if (cfeeAmount.runtimeType != Null)
        feeAmount = cfeeAmount.toString();
      else
        feeAmount = '100';
    });
  }

  void getFeeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String feeTokenString = prefs.getString('feeToken');
      if (feeTokenString.runtimeType != Null) {
        feeToken = Token.fromString(feeTokenString);
      } else {
        feeToken = Token(assetName: "Kira", ticker: 'KEX', denomination: "ukex", decimals: 6);
      }
    });
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
                            !initialFetched ? addLoadingIndicator() : filteredProposals.isEmpty ? Container(
                                margin: EdgeInsets.only(top: 20, left: 20),
                                child: Text("No proposals to show",
                                    style: TextStyle(
                                        color: KiraColors.white, fontSize: 18, fontWeight: FontWeight.bold)))
                                : addProposalsTable(),
                          ],
                        ),
                      )));
            }));
  }

  Widget addLoadingIndicator() {
    return Container(
        alignment: Alignment.center,
        child: Container(
          width: 20,
          height: 20,
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          padding: EdgeInsets.all(0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ));
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
            query = newText.toLowerCase();
            expandedId = "";
            filteredProposals.clear();
            filteredProposals.addAll(query.isEmpty ? proposals : proposals.where((x) => x.proposalId.contains(query) ||
                x.content.getName().toLowerCase().contains(query) || x.getStatusString().toLowerCase().contains(query)));
            proposalController.add(null);
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
      margin: EdgeInsets.only(right: 40, bottom: 20),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text("ID",
                textAlign: TextAlign.center,
                style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text("Title",
                textAlign: TextAlign.center,
                style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: Text("Status",
                textAlign: TextAlign.center,
                style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: Text("Time",
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
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
              isFiltering: query.isNotEmpty,
              proposals: filteredProposals,
              voteable: voteable,
              expandedId: expandedId,
              onTapRow: (id) => this.setState(() {
                expandedId = id;
              }),
              totalPages: (proposalService.totalCount / 5).ceil(),
              controller: proposalController,
              onTapVote: (proposalId, option) => sendProposal(proposalId, option),
            ),
          ],
        ));
  }

  showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
            contentWidgets: [
              Text(Strings.kiraNetwork,
                style: TextStyle(fontSize: 22, color: KiraColors.kPurpleColor, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 15),
              Text(Strings.loading,
                  style: TextStyle(fontSize: 20, color: KiraColors.black, fontWeight: FontWeight.w600)),
              SizedBox(height: 15),
              TextButton(
                  onPressed: () async {
                    cancelTransaction(pendingTxHash);
                  },
                  child: SizedBox(
                      width: 100,
                      height: 36,
                      child: Center(
                          child: Text(
                            Strings.cancel,
                            style: TextStyle(fontSize: 14, color: KiraColors.danger),
                          ))
                  )),
            ]
        );
      },
    );
  }

  cancelTransaction(String txHash) async {
    final message = MsgSend(
        fromAddress: currentAccount.bech32Address,
        toAddress: currentAccount.bech32Address,
        amount: [StdCoin(denom: feeToken.denomination, amount: '1')]);
    final feeV = StdCoin(amount: feeAmount + '0', denom: feeToken.denomination);
    final fee = StdFee(gas: '2000000', amount: [feeV]);

    final stdTx = TransactionBuilder.buildStdTx([message], stdFee: fee, memo: 'Cancel transaction');

    try {
      final signedStdTx = await TransactionSigner.signStdTx(currentAccount, stdTx, accountNumber: lastAccountNumber, sequence: lastSequence);
      await TransactionSender.broadcastStdTx(account: currentAccount, stdTx: signedStdTx);
    } catch (error) {
    }
  }

  sendProposal(String proposalId, int option) async {
    final vote = MsgVote(voter: currentAccount.bech32Address, proposalId: proposalId, option: option);

    final feeV = StdCoin(amount: feeAmount, denom: feeToken.denomination);
    final fee = StdFee(gas: '200000', amount: [feeV]);
    final voteTx = TransactionBuilder.buildVoteTx([vote], stdFee: fee, memo: 'Vote to proposal $proposalId');

    showLoading();

    var result;
    try {
      // Sign the transaction
      final signedVoteTx = await TransactionSigner.signVoteTx(currentAccount, voteTx);
      lastProposalId = proposalId;
      lastOption = option;
      lastAccountNumber = signedVoteTx.accountNumber;
      lastSequence = signedVoteTx.sequence;

      // Broadcast signed transaction
      result = await TransactionSender.broadcastVoteTx(account: currentAccount, voteTx: signedVoteTx);
    } catch (error) {
      result = error.toString();
    }
    Navigator.of(context, rootNavigator: true).pop();

    String voteResult, txHash;
    if (result is String) {
      if (result.contains("-")) result = jsonDecode(result.split("-")[1])['message'];
      voteResult = result;
    } else if (result == false) {
      voteResult = Strings.invalidVote;
    } else if (result['height'] == "0") {
      if (result['check_tx']['log'].toString().contains("invalid")) voteResult = Strings.invalidVote;
    } else {
      txHash = result['hash'];
      if (result['deliver_tx']['log'].toString().contains("failed")) {
        voteResult = result['deliver_tx']['log'].toString();
      } else {
        voteResult = Strings.voteSuccess;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          contentWidgets: [
            Text(Strings.kiraNetwork,
              style: TextStyle(fontSize: 22, color: KiraColors.kPurpleColor, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 15),
            Text(voteResult.isEmpty ? Strings.invalidVote : voteResult,
                style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
            SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(text: new TextSpan(children: [
                  new TextSpan(text: 'TxHash: ', style: TextStyle(color: KiraColors.black)),
                  new TextSpan(
                      text: '0x$txHash'.replaceRange(7, txHash.length - 3, '....'),
                      style: TextStyle(color: KiraColors.kPrimaryColor),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () { Navigator.pushReplacementNamed(context, '/transactions/0x$txHash'); }
                  ),
                ])),
                InkWell(
                  onTap: () {
                    copyText("0x$txHash");
                    showToast(Strings.txHashCopied);
                  },
                  child: Icon(Icons.copy, size: 20, color: KiraColors.kPrimaryColor),
                )
              ],
            )
          ],
        );
      },
    );
  }
}
