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
import 'package:kira_auth/bloc/account_bloc.dart';

class DepositScreen extends StatefulWidget {
  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  StatusService statusService = StatusService();
  GravatarService gravatarService = GravatarService();
  DepositTransactionsTable txTable = DepositTransactionsTable();

  Account currentAccount;
  String networkId;
  Timer timer;
  List<String> networkIds = [];
  bool copied1, copied2;

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        networkIds.add(statusService.nodeInfo.network);
        networkId = statusService.nodeInfo.network;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    this.copied1 = false;
    this.copied2 = false;
    getNodeStatus();

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
                  childWidget: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    addHeaderText(),
                    if (currentAccount != null) addGravatar(context),
                    addNetworkId(context),
                    addDepositAddress(context),
                    addQrCode(context),
                    addDepositTransactionsTable(),
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
    final String gravatar = gravatarService.getIdenticon(
        currentAccount != null ? currentAccount.bech32Address : "");

    final String reducedAddress = currentAccount.bech32Address
        .replaceRange(8, currentAccount.bech32Address.length - 4, '....');

    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                FlutterClipboard.copy(currentAccount.bech32Address)
                    .then((value) => {
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
                    color: KiraColors.kGrayColor,
                    width: 5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1000),
                  child: SvgPicture.string(
                    gravatar,
                    fit: BoxFit.contain,
                    width: 140,
                    height: 140,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
              child: Text(copied1 ? "Copied" : reducedAddress,
                  style: TextStyle(
                      color: copied1
                          ? KiraColors.green2
                          : KiraColors.kLightPurpleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w300)),
            ),
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
                                copied2 = !copied2;
                              }),
                              if (copied2 == true) {autoPress()}
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
                  opacity: copied2 ? 1.0 : 0.0,
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
                            height: screenSize.height / 35,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.5, color: KiraColors.white),
                                color: KiraColors.green4,
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
                                    color: KiraColors.kBrownColor,
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
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: new Border.all(
                  color: KiraColors.kGrayColor,
                  width: 5,
                ),
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

  Widget addDepositTransactionsTable() {
    return Container(
        margin: EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Deposit Transactions",
                textAlign: TextAlign.start,
                style: TextStyle(color: KiraColors.black, fontSize: 30)),
            SizedBox(height: 30),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 2,
                      color: KiraColors.kLightPurpleColor.withOpacity(0.5)),
                  color: KiraColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: KiraColors.kPurpleColor.withOpacity(0.2),
                        offset: Offset(0, 10), //Shadow starts at x=0, y=8
                        blurRadius: 8)
                  ],
                ),
                child: txTable)
          ],
        ));
  }
}
