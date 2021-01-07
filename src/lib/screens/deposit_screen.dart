import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipboard/clipboard.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/blocs/export.dart';

class DepositScreen extends StatefulWidget {
  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  StatusService statusService = StatusService();
  GravatarService gravatarService = GravatarService();
  TransactionService transactionService = TransactionService();

  Account currentAccount;
  String networkId;
  Timer timer;
  List<String> networkIds = [];
  List<Transaction> transactions = [];
  bool copied1, copied2;

  FocusNode depositNode;
  TextEditingController depositController;

  @override
  void initState() {
    super.initState();

    this.depositNode = FocusNode();
    this.depositController = TextEditingController();
    this.copied1 = false;
    this.copied2 = false;
    getNodeStatus();

    if (mounted) {
      setState(() {
        if (BlocProvider.of<AccountBloc>(context).state.currentAccount != null) {
          currentAccount = BlocProvider.of<AccountBloc>(context).state.currentAccount;
          this.depositController.text = currentAccount != null ? currentAccount.bech32Address : '';
        }
      });
      getDepositTransactions();
    }
  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        networkIds.add(statusService.nodeInfo.network);
        networkId = statusService.nodeInfo.network;
      });
    }
  }

  void getDepositTransactions() async {
    if (currentAccount != null) {
      List<Transaction> wTxs =
          await transactionService.getTransactions(account: currentAccount, max: 100, isWithdrawal: false);

      setState(() {
        transactions = wTxs;
      });
    }
  }

  void getNewTransaction(hash) async {
    Transaction tx = await transactionService.getTransaction(hash: hash);
    setState(() {
      transactions.add(tx);
    });
  }

  void autoPress() {
    timer = new Timer(const Duration(seconds: 2), () {
      setState(() {
        if (copied1) copied1 = false;
        if (copied2) copied2 = false;
      });
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
                  childWidget: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 50, bottom: 50),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            addHeaderTitle(),
                            if (currentAccount != null) addGravatar(context),
                            addInformationBig(context),
                            addDepositTransactionsTable(),
                          ],
                        ),
                      )));
            }));
  }

  Widget addHeaderTitle() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Text(
          Strings.deposit,
          textAlign: TextAlign.left,
          style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
        ));
  }

  Widget addInformationBig(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 70),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: KiraColors.kPurpleColor),
                        color: KiraColors.transparent,
                        borderRadius: BorderRadius.circular(9)),
                    // dropdown below..
                    child: DropdownButtonHideUnderline(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 10, left: 15, bottom: 0),
                            child:
                                Text(Strings.networkId, style: TextStyle(color: KiraColors.kGrayColor, fontSize: 12)),
                          ),
                          ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                                value: networkId,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 32,
                                underline: SizedBox(),
                                onChanged: (String netId) {
                                  setState(() {
                                    networkId = netId;
                                  });
                                },
                                items: networkIds.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Container(
                                        height: 25,
                                        alignment: Alignment.topCenter,
                                        child: Text(value, style: TextStyle(color: KiraColors.white, fontSize: 18))),
                                  );
                                }).toList()),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: 50),
                AppTextField(
                  hintText: Strings.depositAddress,
                  focusNode: depositNode,
                  controller: depositController,
                  textInputAction: TextInputAction.done,
                  maxLines: 1,
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: KiraColors.white,
                    fontFamily: 'NunitoSans',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20),
          Container(
            width: 180,
            height: 180,
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
            padding: EdgeInsets.all(0),
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: new Border.all(
                color: KiraColors.kPurpleColor,
                width: 3,
              ),
            ),
            // dropdown below..
            child: QrImage(
              data: currentAccount != null ? currentAccount.bech32Address : '',
              embeddedImage: AssetImage(Strings.logoImage),
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size(80, 80),
              ),
              version: QrVersions.auto,
              size: 300,
            ),
          ),
        ],
      ),
    );
  }

  Widget addGravatar(BuildContext context) {
    final String gravatar = gravatarService.getIdenticon(currentAccount != null ? currentAccount.bech32Address : "");

    final String reducedAddress =
        currentAccount.bech32Address.replaceRange(10, currentAccount.bech32Address.length - 7, '....');

    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                FlutterClipboard.copy(currentAccount.bech32Address).then((value) => {
                      setState(() {
                        copied1 = !copied1;
                      }),
                      if (copied1 == true) {autoPress()}
                    });
              },
              borderRadius: BorderRadius.circular(500),
              onHighlightChanged: (value) {},
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: new Border.all(
                    color: KiraColors.kPurpleColor,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1000),
                  child: SvgPicture.string(
                    gravatar,
                    fit: BoxFit.contain,
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
              child: Text(copied1 ? "Copied" : reducedAddress,
                  style: TextStyle(
                      color: copied1 ? KiraColors.green2 : KiraColors.white.withOpacity(0.8),
                      fontSize: 15,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w300)),
            ),
          ],
        ));
  }

  Widget addDepositTransactionsTable() {
    return Container(
        margin: EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Deposit Transactions",
              textAlign: TextAlign.start,
              style: TextStyle(color: KiraColors.white, fontSize: 22, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 30),
            Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: KiraColors.kGrayColor.withOpacity(0.2)),
                  color: KiraColors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                        color: KiraColors.kBrownColor.withOpacity(0.1),
                        offset: Offset(0, 5), //Shadow starts at x=0, y=8
                        blurRadius: 8)
                  ],
                ),
                child: new DepositTransactionsTable(transactions: transactions))
          ],
        ));
  }
}
