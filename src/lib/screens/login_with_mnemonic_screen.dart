// import 'dart:html';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:blake_hash/blake_hash.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/services/export.dart';

class LoginWithMnemonicScreen extends StatefulWidget {
  @override
  _LoginWithMnemonicScreenState createState() => _LoginWithMnemonicScreenState();
}

class _LoginWithMnemonicScreenState extends State<LoginWithMnemonicScreen> {
  StatusService statusService = StatusService();
  String cachedAccountString;
  String password = "";
  String mnemonicError = "";
  bool isNetworkHealthy = true;

  String passwordError = "";
  FocusNode passwordFocusNode;
  TextEditingController passwordController;

  FocusNode mnemonicFocusNode;
  TextEditingController mnemonicController;

  void getCachedAccountString() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cachedAccountString = prefs.getString('accounts');
    });
  }

  @override
  void initState() {
    super.initState();

    mnemonicFocusNode = FocusNode();
    mnemonicController = TextEditingController();

    getNodeStatus();
    getCachedAccountString();
  }

  void getNodeStatus() async {
    await statusService.getNodeStatus();

    if (mounted) {
      setState(() {
        if (statusService.nodeInfo.network.isNotEmpty) {
          DateTime latestBlockTime = DateTime.tryParse(statusService.syncInfo.latestBlockTime);
          isNetworkHealthy = DateTime.now().difference(latestBlockTime).inMinutes > 1 ? false : true;
        } else {
          isNetworkHealthy = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    // // Set password from param
    // if (arguments != null && password == '') {
    //   setState(() {
    //     password = arguments['password'];
    //   });
    // }

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
                      addDescription(),
                      addPassword(),
                      addMnemonic(),
                      ResponsiveWidget.isSmallScreen(context) ? addButtonsSmall() : addButtonsBig(),
                      ResponsiveWidget.isSmallScreen(context) ? SizedBox(height: 20) : SizedBox(height: 150),
                    ],
                  )),
            )));
  }

  Widget addHeaderTitle() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Text(
          Strings.loginWithMnemonic,
          textAlign: TextAlign.left,
          style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
        ));
  }

  Widget addDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.loginDescription,
            textAlign: TextAlign.left,
            style: TextStyle(color: KiraColors.green3, fontSize: 18),
          ))
        ]));
  }

  Widget addPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          hintText: Strings.password,
          labelText: Strings.password,
          focusNode: passwordFocusNode,
          controller: passwordController,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          autocorrect: false,
          keyboardType: TextInputType.text,
          obscureText: true,
          textAlign: TextAlign.left,
          onChanged: (String text) {
            if (text != "") {
              setState(() {
                passwordError = '';
                password = text;
              });
            }
          },
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 23.0,
            color: KiraColors.white,
            fontFamily: 'NunitoSans',
          ),
        ),
        SizedBox(height: 10),
        Container(
          alignment: AlignmentDirectional(0, 0),
          margin: EdgeInsets.only(top: 3),
          child: Text(this.passwordError == null ? "" : passwordError,
              style: TextStyle(
                fontSize: 13.0,
                color: KiraColors.kYellowColor,
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
              )),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget addMnemonic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          hintText: Strings.mnemonicWords,
          labelText: Strings.mnemonicWords,
          focusNode: mnemonicFocusNode,
          controller: mnemonicController,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          autocorrect: false,
          keyboardType: TextInputType.text,
          textAlign: TextAlign.left,
          onChanged: (String text) {
            if (text == '') {
              setState(() {
                mnemonicError = "";
              });
            }
          },
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18.0,
            color: KiraColors.white,
            fontFamily: 'NunitoSans',
          ),
        ),
        SizedBox(height: 15),
        Container(
          alignment: AlignmentDirectional(0, 0),
          margin: EdgeInsets.only(top: 3),
          child: Text(this.mnemonicError == null ? "" : mnemonicError,
              style: TextStyle(
                fontSize: 13.0,
                color: KiraColors.kYellowColor,
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
              )),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  void onLogin() {
    if (password == "") {
      this.setState(() {
        passwordError = Strings.passwordBlank;
      });
    }

    String mnemonic = mnemonicController.text;

    // Check if mnemonic is valid
    if (bip39.validateMnemonic(mnemonic) == false) {
      setState(() {
        mnemonicError = "Invalid Mnemonic";
      });
      return;
    }

    if (cachedAccountString == null) {
      setState(() {
        mnemonicError = Strings.createAccountError;
      });
      return;
    }

    List<int> bytes = utf8.encode(password);

    // Get hash value of password and use it to encrypt mnemonic
    var hashDigest = Blake256().update(bytes).digest();
    String secretKey = String.fromCharCodes(hashDigest);

    var array = cachedAccountString.split('---');
    bool isPasswordCorrect = false;

    for (int index = 0; index < array.length; index++) {
      if (array[index].length > 5) {
        Account account = Account.fromString(array[index]);
        if (decryptAESCryptoJS(account.checksum, secretKey) == 'kira') {
          BlocProvider.of<AccountBloc>(context).add(SetCurrentAccount(account));
          BlocProvider.of<ValidatorBloc>(context).add(GetCachedValidators(account.hexAddress));

          setPassword(password);

          Navigator.pushReplacementNamed(context, '/deposit');
          isPasswordCorrect = true;
        }
      }
    }

    if (isPasswordCorrect == false) {
      setState(() {
        mnemonicError = "Password is wrong. Please go back and input correct password";
      });
    }
  }

  Widget addButtonsSmall() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomButton(
              key: Key('log_in'),
              text: Strings.login,
              height: 60,
              style: 2,
              onPressed: () {
                this.onLogin();
              },
            ),
            SizedBox(height: 30),
            CustomButton(
              key: Key('go_back'),
              text: Strings.back,
              height: 60,
              style: 1,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ]),
    );
  }

  Widget addButtonsBig() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CustomButton(
              key: Key('go_back'),
              text: Strings.back,
              width: 220,
              height: 60,
              style: 1,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            CustomButton(
              key: Key('log_in'),
              text: Strings.login,
              width: 220,
              height: 60,
              style: 2,
              onPressed: () {
                this.onLogin();
              },
            ),
          ]),
    );
  }
}
