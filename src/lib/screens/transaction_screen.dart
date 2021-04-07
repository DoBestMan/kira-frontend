import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/models/export.dart';

class TransactionScreen extends StatefulWidget {
  final String txHash;
  const TransactionScreen(String txHash) : this.txHash = txHash;

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  NetworkService networkService = NetworkService();
  StatusService statusService = StatusService();

  BlockTransaction transaction;
  bool isNetworkHealthy = false;

  @override
  void initState() {
    super.initState();
    getNodeStatus();
    getTransaction();
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

  void getTransaction() async {
    if ((widget.txHash ?? '').isNotEmpty)
      await networkService.searchTransaction(widget.txHash);
    if (mounted) {
      setState(() {
        transaction = networkService.transaction;
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
                            Container(
                                margin: EdgeInsets.only(bottom: 40),
                                child: Text(
                                  Strings.txDetails,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
                                )
                            ),
                            transaction != null ? addTransactionDetails() : CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ],
                        ),
                      )));
            }));
  }

  Widget addTransactionDetails() {
    final fieldWidth = ResponsiveWidget.isSmallScreen(context) ? 80.0 : 150.0;

    return Card(
        color: KiraColors.purple1.withOpacity(0.2),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: fieldWidth,
                    child: Text("Transaction Hash",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 20),
                  Flexible(
                      child: InkWell(
                          onTap: () {
                            copyText(transaction.getHash);
                            showToast(Strings.txHashCopied);
                          },
                          child: Text(transaction.getHash,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))
                      ))
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
                            color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 20),
                  Container(
                      padding: EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 4),
                      child: Text(transaction.status, style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 16)),
                      decoration: BoxDecoration(
                          color: KiraColors.purple1.withOpacity(0.8), borderRadius: BorderRadius.circular(4)))
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: fieldWidth,
                    child: Text("Block",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 20),
                  Text(transaction.getHeightString(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14))
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: fieldWidth,
                    child: Text("Timestamp",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 20),
                  Text(
                    transaction.getLongTimeString(),
                    style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14),
                  )
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: fieldWidth,
                    child: Text("Voter",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 20),
                  Flexible(
                      child: InkWell(
                          onTap: () {
                            copyText(transaction.getVoter);
                            showToast(Strings.voterCopied);
                          },
                          child: Text(transaction.getVoter,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14),
                          ))
                  )
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: fieldWidth,
                    child: Text("Vote Option",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 20),
                  Flexible(
                      child: Text(transaction.getVoteOption,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14),
                      ))
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: fieldWidth,
                    child: Text("Proposal",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: KiraColors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 20),
                  Flexible(
                      child: Text(transaction.getProposalId,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: KiraColors.white.withOpacity(0.8), fontSize: 14),
                      ))
                ],
              ),
            ],
          ),
        ));
  }
}
