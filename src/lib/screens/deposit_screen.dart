import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipboard/clipboard.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jdenticon/jdenticon.dart';

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
  Timer timer;
  String networkId = Strings.noAvailableNetworks;
  List<String> networkIds = [Strings.noAvailableNetworks];
  List<Transaction> transactions = [];
  bool copied1, copied2, isNetworkHealthy = false;

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
    }
    getDepositTransactions();
  }

  @override
  void dispose() {
    depositController.dispose();
    super.dispose();
  }

  void unmount() {
    timer.cancel();
  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        if (statusService.nodeInfo != null && statusService.nodeInfo.network.isNotEmpty) {
          networkIds.clear();
          networkIds.add(statusService.nodeInfo.network);
          networkId = statusService.nodeInfo.network;
          isNetworkHealthy = statusService.isNetworkHealthy;
          BlocProvider.of<NetworkBloc>(context)
              .add(SetNetworkInfo(statusService.nodeInfo.network, statusService.rpcUrl));
        } else {
          isNetworkHealthy = false;
        }
      });
    }
  }

  void getDepositTransactions() async {
    if (currentAccount != null) {
      List<Transaction> wTxs =
      await transactionService.getTransactions(account: currentAccount, max: 100, isWithdrawal: false);

      if (mounted) {
        setState(() {
          transactions = wTxs;
        });
      }
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
                  isNetworkHealthy: isNetworkHealthy,
                  childWidget: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 50, bottom: 50),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            addHeaderTitle(),
                            if (currentAccount != null) addGravatar(context),
                            ResponsiveWidget.isSmallScreen(context) ? addInformationSmall() : addInformationBig(),
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

  Widget availableNetworks() {
    return Container(
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
                child: Text(Strings.availableNetworks, style: TextStyle(color: KiraColors.kGrayColor, fontSize: 12)),
              ),
              ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                    dropdownColor: KiraColors.kPurpleColor,
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
        ));
  }

  Widget depositAddress() {
    return AppTextField(
      hintText: Strings.depositAddress,
      labelText: Strings.depositAddress,
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
    );
  }

  Widget qrCode() {
    return Container(
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
        embeddedImage: AssetImage(Strings.logoQRImage),
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size(60, 60),
        ),
        version: QrVersions.auto,
        size: 300,
      ),
    );
  }

  Widget addInformationBig() {
    return Container(
      margin: EdgeInsets.only(bottom: 70),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                availableNetworks(),
                SizedBox(height: 50),
                depositAddress(),
              ],
            ),
          ),
          SizedBox(width: 30),
          qrCode(),
          SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget addInformationSmall() {
    return Container(
      margin: EdgeInsets.only(bottom: 70),
      child: Column(
        children: [
          availableNetworks(),
          SizedBox(height: 30),
          depositAddress(),
          SizedBox(height: 30),
          qrCode(),
        ],
      ),
    );
  }

  Widget addGravatar(BuildContext context) {
    // final String gravatar = gravatarService.getIdenticon(currentAccount != null ? currentAccount.bech32Address : "");

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
                width: 75,
                height: 75,
                padding: EdgeInsets.all(2),
                decoration: new BoxDecoration(
                  color: KiraColors.kPurpleColor,
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1000),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: SvgPicture.string(
                      Jdenticon.toSvg(currentAccount.bech32Address, 100, 10),
                      fit: BoxFit.contain,
                      height: 70,
                      width: 70,
                    ),
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
              child: InkWell(
                onTap: () {
                  copyText(currentAccount.bech32Address);
                  showToast(Strings.publicAddressCopied);
                },
                child: Text(copied1 ? Strings.copied : reducedAddress,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      fontFamily: 'NunitoSans',
                      color: copied1 ? KiraColors.green3 : KiraColors.white.withOpacity(0.8),
                      letterSpacing: 1,
                    )),
              ),
            ),
          ],
        ));
  }

  Widget addDepositTransactionsTable() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Strings.depositTransactions,
              textAlign: TextAlign.start,
              style: TextStyle(color: KiraColors.white, fontSize: 20, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 20),
            DepositTransactionsTable(transactions: transactions)
          ],
        ));
  }
}
