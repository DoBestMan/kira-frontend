import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/utils/responsive.dart';
import 'package:kira_auth/config.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StatusService statusService = StatusService();
  List<String> networkIds = [Strings.customNetwork];
  String networkId = Strings.customNetwork;
  bool isLoading = false, isHover = false, isNetworkHealthy = false, isError = false;

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
    // getInterxRPCUrl();
  }

  @override
  void dispose() {
    rpcUrlController.dispose();
    super.dispose();
  }

  void getNodeStatus() async {
    if (mounted) {
      try {
        await statusService.getNodeStatus();
        setState(() {
          if (statusService.nodeInfo.network.isNotEmpty) {
            if (!networkIds.contains(statusService.nodeInfo.network)) {
              networkIds.add(statusService.nodeInfo.network);
            }
            networkId = statusService.nodeInfo.network;
            BlocProvider.of<NetworkBloc>(context).add(SetNetworkId(networkId));

            DateTime latestBlockTime = DateTime.tryParse(statusService.syncInfo.latestBlockTime);
            isNetworkHealthy = DateTime.now().difference(latestBlockTime).inMinutes > 1 ? false : true;
          } else {
            isNetworkHealthy = false;
          }
          isLoading = false;
          isError = false;
        });
      } catch (e) {
        setState(() {
          isNetworkHealthy = false;
          isLoading = false;
          isError = true;
        });
      }
    }
  }

  void checkNodeStatus() async {
    try {
      bool status = await statusService.checkNodeStatus();
      setState(() {
        isNetworkHealthy = status;
        isLoading = false;
        isError = !status;
      });
    } catch (e) {
      setState(() {
        isNetworkHealthy = false;
        isLoading = false;
        isError = true;
      });
    }
  }

  void getInterxRPCUrl() async {
    rpcUrlController.text = await loadConfig();
  }

  void disconnect() {
    setState(() {
      isNetworkHealthy = false;
    });
    rpcUrlController.text = "";
    String customInterxRPCUrl = rpcUrlController.text;
    setInterxRPCUrl(customInterxRPCUrl);
    Future.delayed(const Duration(milliseconds: 500), () async {
      checkNodeStatus();
    });
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
                      if (networkId == Strings.customNetwork) addCustomRPC(),
                      if (isLoading == true) addLoadingIndicator(),
                      // addErrorMessage(),
                      if (networkId == Strings.customNetwork && isNetworkHealthy == false && isLoading == false)
                        addConnectButton(context),
                      isNetworkHealthy == true && isLoading == false
                          ? Column(
                              children: [
                                ResponsiveWidget.isSmallScreen(context) ? addLoginButtonsSmall() : addLoginButtonsBig(),
                                addCreateNewAccount(),
                              ],
                            )
                          : Container(),
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
                          BlocProvider.of<NetworkBloc>(context).add(SetNetworkId(networkId));
                          if (networkId == "Custom Network") {
                            disconnect();
                          }
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
        labelText: Strings.rpcURL,
        focusNode: rpcUrlNode,
        controller: rpcUrlController,
        textInputAction: TextInputAction.done,
        isWrong: isError,
        maxLines: 1,
        autocorrect: false,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.left,
        onChanged: (String text) {
          setState(() {
            isNetworkHealthy = false;
          });
        },
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: KiraColors.white,
          fontFamily: 'NunitoSans',
        ),
      ),
      SizedBox(height: 30)
    ]);
  }

  Widget addConnectButton(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: CustomButton(
          key: Key(Strings.connect),
          text: Strings.connect,
          height: 60,
          style: 2,
          onPressed: () {
            setState(() {
              isLoading = true;
              isNetworkHealthy = false;
            });

            String customInterxRPCUrl = rpcUrlController.text;
            setInterxRPCUrl(customInterxRPCUrl);

            Future.delayed(const Duration(milliseconds: 500), () async {
              getNodeStatus();
            });
            //getNodeStatus();
            //getInterxRPCUrl();
          },
        ));
  }

  Widget addDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.networkDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: KiraColors.green3, fontSize: 18),
          ))
        ]));
  }

  Widget addLoginWithKeyFileButton(isBigScreen) {
    return CustomButton(
      key: Key(Strings.loginWithKeyFile),
      text: Strings.loginWithKeyFile,
      width: isBigScreen ? 220 : null,
      height: 60,
      style: 2,
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
      key: Key(Strings.loginWithMnemonic),
      text: Strings.loginWithMnemonic,
      width: isBigScreen ? 220 : null,
      height: 60,
      style: 1,
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
            addLoginWithMnemonicButton(true),
            addLoginWithKeyFileButton(true),
          ]),
    );
  }

  Widget addLoadingIndicator() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        alignment: Alignment.center,
        child: Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          padding: EdgeInsets.all(0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ));
  }

  Widget addErrorMessage() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: isError ? 30 : 0, top: isError ? 20 : 0),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: AlignmentDirectional(0, 0),
                  child: Text(Strings.invalidUrl,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: KiraColors.kYellowColor,
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.w300,
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
        key: Key(Strings.createNewAccount),
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
