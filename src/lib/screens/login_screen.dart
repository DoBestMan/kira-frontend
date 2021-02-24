import 'package:flutter/material.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/utils/responsive.dart';
import 'package:kira_auth/config.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StatusService statusService = StatusService();
  List<String> networkIds = ["Custom Network"];
  String networkId, error = "";
  bool loading = true, isHover = false, isNetworkHealthy = true;

  HeaderWrapper headerWrapper;
  FocusNode rpcUrlNode;
  TextEditingController rpcUrlController;

  @override
  void initState() {
    // removeCachedAccount();
    super.initState();

    rpcUrlNode = FocusNode();
    rpcUrlController = TextEditingController();

    getNodeStatus();
    getInterxRPCUrl();
  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        loading = false;
        if (statusService.nodeInfo.network.isNotEmpty) {
          networkIds.add(statusService.nodeInfo.network);
          networkId = statusService.nodeInfo.network;

          DateTime latestBlockTime = DateTime.tryParse(statusService.syncInfo.latestBlockTime);
          isNetworkHealthy = DateTime.now().difference(latestBlockTime).inMinutes > 1 ? false : true;
        } else {
          networkId = "Custom Network";
          isNetworkHealthy = false;
        }
      });
    }
  }

  void checkNodeStatus() async {
    bool status = await statusService.checkNodeStatus();
    setState(() {
      isNetworkHealthy = status;
    });
  }

  void getInterxRPCUrl() async {
    rpcUrlController.text = await loadConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: HeaderWrapper(
            isNetworkHealthy: isNetworkHealthy,
            childWidget: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 50, bottom: 50),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      addHeaderTitle(),
                      addNetworks(context),
                      if (networkId == "Custom Network") addCustomRPC(),
                      if (networkId == "Custom Network") addCheckCustomRpc(context),
                      addErrorMessage(),
                      ResponsiveWidget.isSmallScreen(context) ? addLoginButtonsSmall() : addLoginButtonsBig(),
                      addCreateNewAccount(),
                    ],
                  ),
                ))));
  }

  Widget addHeaderTitle() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Text(
          Strings.login,
          textAlign: TextAlign.left,
          style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
        ));
  }

  Widget addNetworks(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Container(
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
                  child: Text(Strings.networkId, style: TextStyle(color: KiraColors.kGrayColor, fontSize: 12)),
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
    );
  }

  Widget addCustomRPC() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppTextField(
        hintText: "interx.servicenet.local (0.0.0.0:11000)",
        labelText: Strings.rpcURL,
        focusNode: rpcUrlNode,
        controller: rpcUrlController,
        textInputAction: TextInputAction.done,
        maxLines: 1,
        autocorrect: false,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.left,
        onChanged: (String text) {
          setState(() {
            var urlPattern = r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]{1,5}$";
            RegExp regex = new RegExp(urlPattern, caseSensitive: false);

            if (!regex.hasMatch(text)) {
              error = Strings.invalidUrl;
            } else {
              error = "";
            }
          });
        },
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: KiraColors.white,
          fontFamily: 'NunitoSans',
        ),
      ),
      SizedBox(height: 10)
    ]);
  }

  Widget addCheckCustomRpc(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
                onHover: (value) {
                  setState(() {
                    isHover = value ? true : false;
                  });
                },
                onTap: () {
                  setState(() {
                    isNetworkHealthy = false;
                  });
                  String customInterxRPCUrl = rpcUrlController.text;
                  if (customInterxRPCUrl.length > 0) {
                    setInterxRPCUrl(customInterxRPCUrl);
                  }
                  checkNodeStatus();
                },
                child: Text(
                  Strings.check,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: KiraColors.green3,
                    fontSize: 14,
                    decoration: isHover ? TextDecoration.underline : null,
                  ),
                )),
            SizedBox(width: 20),
            Text(
              isNetworkHealthy ? "" : Strings.invalidUrl,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: isNetworkHealthy ? KiraColors.green3 : KiraColors.kYellowColor,
                fontSize: 14,
              ),
            )
          ]),
    );
  }

  Widget addDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.networkDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: KiraColors.green2, fontSize: 18),
          ))
        ]));
  }

  Widget addLoginWithKeyFileButton(isBigScreen) {
    return CustomButton(
      key: Key('login_with_keyfile'),
      text: Strings.loginWithKeyFile,
      width: isBigScreen ? 220 : null,
      height: 60,
      style: 1,
      onPressed: () {
        String customInterxRPCUrl = rpcUrlController.text;
        if (customInterxRPCUrl.length > 0) {
          setInterxRPCUrl(customInterxRPCUrl);
        }
        Navigator.pushReplacementNamed(context, '/login-keyfile');
      },
    );
  }

  Widget addLoginWithMnemonicButton(isBigScreen) {
    return CustomButton(
      key: Key('login_with_mnemonic'),
      text: Strings.loginWithMnemonic,
      width: isBigScreen ? 220 : null,
      height: 60,
      style: 2,
      onPressed: () {
        String customInterxRPCUrl = rpcUrlController.text;
        if (customInterxRPCUrl.length > 0) {
          setInterxRPCUrl(customInterxRPCUrl);
        }
        Navigator.pushReplacementNamed(context, '/login-mnemonic');
      },
    );
  }

  Widget addLoginButtonsBig() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            addLoginWithKeyFileButton(true),
            addLoginWithMnemonicButton(true),
          ]),
    );
  }

  Widget addErrorMessage() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: this.error.isNotEmpty ? 30 : 0),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: AlignmentDirectional(0, 0),
                  child: Text(this.error == null ? "" : error,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: KiraColors.kYellowColor,
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
          ],
        ));
  }

  Widget addLoginButtonsSmall() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            addLoginWithKeyFileButton(false),
            SizedBox(height: 30),
            addLoginWithMnemonicButton(false),
          ]),
    );
  }

  Widget addCreateNewAccount() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Ink(
        child: Text(
          "or",
          textAlign: TextAlign.center,
          style: TextStyle(color: KiraColors.kGrayColor, fontSize: 16),
        ),
      ),
      SizedBox(height: 20),
      CustomButton(
        key: Key('create_account'),
        text: Strings.createNewAccount,
        fontSize: 18,
        height: 60,
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/create-account');
        },
      )
    ]);
  }
}
