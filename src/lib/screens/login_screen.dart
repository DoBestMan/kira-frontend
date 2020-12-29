import 'package:flutter/material.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/widgets/export.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StatusService statusService = StatusService();
  List<String> networkIds = [];
  String networkId;
  String passwordError;
  bool loading;

  FocusNode passwordFocusNode;
  TextEditingController passwordController;

  @override
  void initState() {
    // removeCachedAccount();
    super.initState();

    loading = true;

    this.passwordFocusNode = FocusNode();
    this.passwordController = TextEditingController();

    getNodeStatus();
  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        loading = false;
        networkIds.add(statusService.nodeInfo.network);
        networkId = statusService.nodeInfo.network;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: HeaderWrapper(
            childWidget: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          addHeaderText(),
          // addDescription(),
          addNetworkId(context),
          addPassword(),
          addCreateNewAccount(),
          addLoginWithMnemonic(),
          addLoginWithKeyFile(),
        ],
      ),
    )));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Text(
          Strings.login,
          textAlign: TextAlign.center,
          style: TextStyle(color: KiraColors.black, fontSize: 40, fontWeight: FontWeight.w900),
        ));
  }

  Widget addPassword() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Strings.password, style: TextStyle(color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: MediaQuery.of(context).size.width * (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    topMargin: 20,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    focusNode: passwordFocusNode,
                    controller: passwordController,
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    textAlign: TextAlign.left,
                    onChanged: (String password) {
                      if (password != "") {
                        setState(() {
                          passwordError = null;
                        });
                      }
                    },
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                      color: KiraColors.kPrimaryColor,
                      fontFamily: 'NunitoSans',
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
            Container(
              alignment: AlignmentDirectional(0, 0),
              margin: EdgeInsets.only(top: 3),
              child: Text(this.passwordError == null ? "" : passwordError,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: KiraColors.kYellowColor,
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ));
  }

  Widget addNetworkId(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(Strings.networkId, style: TextStyle(color: KiraColors.kPurpleColor, fontSize: 20)),
            Container(
                width: MediaQuery.of(context).size.width * (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.32),
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: KiraColors.kPrimaryColor),
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
                        items: networkIds.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(color: KiraColors.kPurpleColor, fontSize: 18)),
                          );
                        }).toList()),
                  ),
                )),
            SizedBox(height: 20),
          ],
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
            style: TextStyle(color: KiraColors.green2, fontSize: 18),
          ))
        ]));
  }

  Widget addCreateNewAccount() {
    return Container(
        width: MediaQuery.of(context).size.width * (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('create_account'),
          text: Strings.createNewAccount,
          height: 44.0,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/create-account');
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addLoginWithMnemonic() {
    return Container(
        width: MediaQuery.of(context).size.width * (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('login_with_mnemonic'),
          text: Strings.loginWithMnemonic,
          height: 44.0,
          onPressed: () {
            if (passwordController.text != "") {
              Navigator.pushReplacementNamed(context, '/login-mnemonic',
                  arguments: {'password': '${passwordController.text}'});
            } else {
              this.setState(() {
                passwordError = "Password required";
              });
            }
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addLoginWithKeyFile() {
    return Container(
        width: MediaQuery.of(context).size.width * (ResponsiveWidget.isSmallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('login_with_keyfile'),
          text: Strings.loginWithKeyFile,
          height: 44.0,
          onPressed: () {
            if (passwordController.text != "") {
              Navigator.pushReplacementNamed(context, '/login-keyfile',
                  arguments: {'password': '${passwordController.text}'});
            } else {
              this.setState(() {
                passwordError = "Password required";
              });
            }
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }
}
