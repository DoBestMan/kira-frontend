import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:html' as html;
import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StatusService statusService = StatusService();
  List<String> networkIds = [Strings.customNetwork];
  String networkId = Strings.customNetwork;
  String testedRpcUrl = "";
  bool isLoading = false, isHover = false, isNetworkHealthy = false, isRpcError = false;

  HeaderWrapper headerWrapper;
  FocusNode rpcUrlNode;
  TextEditingController rpcUrlController;

  @override
  void initState() {

    super.initState();


    var uri = Uri.dataFromString(html.window.location.href); //converts string to a uri
    Map<String, String> params = uri.queryParameters; // query parameters automatically populated

    if(params.containsKey("rpc")) {
      var rpcURL = params['rpc'];
      onConnectPressed(rpcURL);
      print(rpcURL);
    }

    setTopBarStatus(false);
    setLoginStatus(false);
    rpcUrlNode = FocusNode();
    rpcUrlController = TextEditingController();
    getNodeStatus(true);
    // getInterxRPCUrl();
  }

  @override
  void dispose() {
    rpcUrlController.dispose();
    rpcUrlNode.dispose();
    super.dispose();
  }

  void getNodeStatus(bool inited) async {
    if (mounted) {
      try {
        await statusService.getNodeStatus();
        // setState(() {
        testedRpcUrl = statusService.rpcUrl;
        if (statusService.nodeInfo != null && statusService.nodeInfo.network.isNotEmpty) {
          setState(() {
            if (!networkIds.contains(statusService.nodeInfo.network)) {
              networkIds.add(statusService.nodeInfo.network);
            }
            networkId = statusService.nodeInfo.network;
            isNetworkHealthy = statusService.isNetworkHealthy;
            isRpcError = false;
          });
          BlocProvider.of<NetworkBloc>(context).add(SetNetworkInfo(networkId, testedRpcUrl));
        } else {
          isNetworkHealthy = false;
        }
        isLoading = false;
        // });
      } catch (e) {
        print("ERROR OCCURED");
        setState(() {
          testedRpcUrl = statusService.rpcUrl;
          isNetworkHealthy = false;
          isLoading = false;
          if (inited == false) isRpcError = true;
        });
      }
    }
  }

  // void checkNodeStatus() async {
  //   if (mounted) {
  //     try {
  //       bool status = await statusService.checkNodeStatus();
  //       setState(() {
  //         isNetworkHealthy = status;
  //         isLoading = false;
  //         // isRpcError = !status;
  //       });
  //     } catch (e) {
  //       setState(() {
  //         isNetworkHealthy = false;
  //         isLoading = false;
  //         // isRpcError = true;
  //       });
  //     }
  //   }
  // }

  void getInterxRPCUrl() async {
    var apiUrl = await loadInterxURL();
    rpcUrlController.text = apiUrl[0];
  }

  void disconnect() {
    if (mounted) {
      setState(() {
        isRpcError = false;
        isNetworkHealthy = false;
      });
      rpcUrlController.text = "";
      String customInterxRPCUrl = rpcUrlController.text;
      setInterxRPCUrl(customInterxRPCUrl);
      // Future.delayed(const Duration(milliseconds: 500), () async {
      //   checkNodeStatus();
      // });
    }
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
                      if (isNetworkHealthy == false) addNetworks(context),
                      if (isNetworkHealthy == false && networkId == Strings.customNetwork) addCustomRPC(),
                      if (isLoading == true) addLoadingIndicator(),
                      // addErrorMessage(),
                      if (networkId == Strings.customNetwork && isNetworkHealthy == false && isLoading == false)
                        addConnectButton(context),
                      isNetworkHealthy == true && isLoading == false
                          ? Column(
                              children: [
                                addLoginButtonsSmall(),
                                addCreateNewAccount(),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ))));
  }

  Widget addHeaderTitle() {
    bool connected = networkId != null && networkId != '' && networkId != Strings.customNetwork;
    String headerTitle = connected ? 'You are connected to ' + networkId : Strings.connect;
    headerTitle = isRpcError && testedRpcUrl != "" ? Strings.failedToConnect : headerTitle;

    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headerTitle,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: isRpcError && testedRpcUrl != "" ? KiraColors.danger : KiraColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900),
              ),
              if (isRpcError && testedRpcUrl != "") SizedBox(height: 20),
              if (isRpcError && testedRpcUrl != "")
                Text(
                  "Node with address " + testedRpcUrl + " could not be reached",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: KiraColors.danger, fontSize: 20, fontWeight: FontWeight.w900),
                ),
              SizedBox(height: 20),
              Text(
                connected ? Strings.selectLoginOption : Strings.selectFullNode,
                textAlign: TextAlign.left,
                style: TextStyle(color: KiraColors.green3, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              if (!connected) SizedBox(height: 15),
              if (!connected)
                Text(
                  Strings.requireSSL,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: KiraColors.white.withOpacity(0.6), fontSize: 15, fontWeight: FontWeight.w300),
                )
            ]));
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
                        if (mounted) {
                          setState(() {
                            networkId = netId;
                            if (networkId == Strings.customNetwork) {
                              disconnect();
                              networkIds.clear();
                              networkIds.add(Strings.customNetwork);
                            }
                          });
                          var nodeAddress = BlocProvider.of<NetworkBloc>(context).state.nodeAddress;
                          BlocProvider.of<NetworkBloc>(context).add(SetNetworkInfo(networkId, nodeAddress));
                        }
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
        isWrong: isRpcError,
        maxLines: 1,
        autocorrect: false,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.left,
        onChanged: (String text) {
          if (mounted) {
            setState(() {
              isNetworkHealthy = false;
              if (text == "") isRpcError = false;
            });
          }
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
            onConnectPressed(rpcUrlController.text);
          },
        ));
  }

  void onConnectPressed(String customInterxRPCUrl) {
    if (mounted) {
      setState(() {
        isLoading = true;
        isNetworkHealthy = false;
      });
    }


    // String customInterxRPCUrl = rpcUrlController.text;
    setInterxRPCUrl(customInterxRPCUrl);

    Future.delayed(const Duration(milliseconds: 500), () async {
      getNodeStatus(false);
    });
    //getNodeStatus();
    //getInterxRPCUrl();
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

  Widget addLoginWithSaifu(isBigScreen) {
    return CustomButton(
      key: Key(Strings.loginWithSaifu),
      text: Strings.loginWithSaifu,
      width: isBigScreen ? 220 : null,
      height: 60,
      style: 2,
      onPressed: () {
        // ToDo: Saifu Integration
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
  Widget addLoginWithExplorerButton(isBigScreen) {
    return CustomButton(
      key: Key(Strings.loginWithExplorer),
      text: Strings.loginWithExplorer,
      width: isBigScreen ? 220 : null,
      height: 60,
      style: 1,
      onPressed: () {
        setLoginStatus(false);
        Navigator.pushReplacementNamed(context, '/account');
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
        margin: EdgeInsets.only(bottom: isRpcError ? 30 : 0, top: isRpcError ? 20 : 0),
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
            // addLoginWithSaifu(false),
            // SizedBox(height: 30),
            addLoginWithKeyFileButton(false),
            SizedBox(height: 30),
            addLoginWithMnemonicButton(false),
            SizedBox(height: 30),
            addLoginWithExplorerButton(false),
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
