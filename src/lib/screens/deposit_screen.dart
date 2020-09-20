import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipboard/clipboard.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/responsive.dart';
import 'package:kira_auth/utils/cache.dart';
import 'package:kira_auth/models/account_model.dart';
import 'package:kira_auth/services/status_service.dart';
import 'package:kira_auth/models/node_info_model.dart';
import 'package:kira_auth/models/sync_info_model.dart';
import 'package:kira_auth/bloc/account_bloc.dart';
import 'package:kira_auth/widgets/header_wrapper.dart';
import 'package:kira_auth/widgets/deposit_transactions_table.dart';

class DepositScreen extends StatefulWidget {
  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  AccountModel currentAccount;
  NodeInfoModel nodeInfo;
  SyncInfoModel syncInfo;
  String networkId;
  Timer timer;
  List<String> networkIds = [];
  bool copied;

  void getNodeStatus() async {
    StatusService statusService = StatusService();
    await statusService.getNodeStatus();

    nodeInfo = statusService.nodeInfo;
    syncInfo = statusService.syncInfo;

    if (mounted) {
      setState(() {
        networkIds.add(nodeInfo.network);
        networkId = nodeInfo.network;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getNodeStatus();

    this.copied = false;

    if (mounted) {
      setState(() {
        if (BlocProvider.of<AccountBloc>(context).state.currentAccount !=
            null) {
          currentAccount =
              BlocProvider.of<AccountBloc>(context).state.currentAccount;
        }
      });
    }
  }

  void autoPress() {
    timer = new Timer(const Duration(seconds: 3), () {
      setState(() {
        copied = !copied;
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
                  childWidget: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    addHeaderText(),
                    addGravatar(context),
                    addNetworkId(context),
                    addDepositAddress(context),
                    addQrCode(context),
                    addDepositTransactionsTable(context),
                  ],
                ),
              ));
            }));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Text(
          "Deposit",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: KiraColors.black,
              fontSize: 40,
              fontWeight: FontWeight.w900),
        ));
  }

  Widget addNetworkId(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(Strings.networkId,
                style: TextStyle(color: KiraColors.kPurpleColor, fontSize: 20)),
            Container(
                width: MediaQuery.of(context).size.width *
                    (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 2, color: KiraColors.kPrimaryColor),
                    color: KiraColors.kPrimaryLightColor,
                    borderRadius: BorderRadius.circular(25)),
                // dropdown below..
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
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
                        items: networkIds
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: TextStyle(
                                    color: KiraColors.kPurpleColor,
                                    fontSize: 18)),
                          );
                        }).toList()),
                  ),
                )),
          ],
        ));
  }

  Widget addGravatar(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 120,
                height: 120,
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: KiraColors.kPrimaryLightColor,
                ),
                // dropdown below..
                child: Image(
                    image: AssetImage(Strings.logoImage),
                    width: 80,
                    height: 80)),
          ],
        ));
  }

  Widget addDepositAddress(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(Strings.deposit,
                style: TextStyle(color: KiraColors.kPurpleColor, fontSize: 20)),
            Stack(children: [
              Center(
                  child: Container(
                width: screenSize.width *
                    (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                height: screenSize.height *
                    (ResponsiveWidget.isSmallScreen(context) ? 0.18 : 0.16),
                margin: EdgeInsets.symmetric(vertical: 25),
                child: FlatButton(
                  color: KiraColors.kPurpleColor,
                  highlightColor: KiraColors.kBrownColor,
                  onPressed: () {
                    FlutterClipboard.copy(currentAccount.bech32Address)
                        .then((value) => {
                              setState(() {
                                copied = !copied;
                              }),
                              if (copied == true) {autoPress()}
                            });
                  },
                  onHighlightChanged: (value) {},
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  // side:
                  //     BorderSide(color: KiraColors.kYellowColor, width: 2.0)),
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            currentAccount != null ? currentAccount.name : '',
                            style: TextStyle(
                              fontSize: 22,
                              color: KiraColors.kYellowColor1,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            currentAccount != null
                                ? currentAccount.bech32Address
                                : '',
                            style: TextStyle(
                              fontSize: 17,
                              color: KiraColors.white,
                            ),
                          ),
                        ],
                      )),
                ),
              )),
              AnimatedOpacity(
                  opacity: copied ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.only(
                          top: screenSize.height *
                              (ResponsiveWidget.isSmallScreen(context)
                                  ? 0.19
                                  : 0.17),
                          left: ResponsiveWidget.isSmallScreen(context)
                              ? screenSize.width / 12
                              : screenSize.width / 5,
                          right: ResponsiveWidget.isSmallScreen(context)
                              ? screenSize.width / 12
                              : screenSize.width / 5,
                        ),
                        child: Container(
                            width: ResponsiveWidget.isSmallScreen(context)
                                ? screenSize.width / 3
                                : screenSize.width / 10,
                            height: screenSize.height / 30,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.5, color: KiraColors.white),
                                color: KiraColors.kYellowColor2,
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Copied',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: KiraColors.white,
                                  ),
                                )
                              ],
                            ))),
                  ))
            ]),
          ],
        ));
  }

  Widget addQrCode(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: KiraColors.kPrimaryLightColor,
              ),
              // dropdown below..
              child: QrImage(
                data:
                    currentAccount != null ? currentAccount.bech32Address : '',
                embeddedImage: AssetImage(Strings.logoImage),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(80, 80),
                ),
                version: QrVersions.auto,
                size: 300,
              ),
            ),
          ],
        ));
  }

  Widget addDepositTransactionsTable(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Deposit Transactions",
                textAlign: TextAlign.left,
                style: TextStyle(color: KiraColors.black, fontSize: 30)),
            SizedBox(height: 30),
            DepositTransactionsTable()
          ],
        ));
  }
}
