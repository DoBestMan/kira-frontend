// import 'dart:html';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:blake_hash/blake_hash.dart';
import 'package:kira_auth/utils/cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kira_auth/widgets/appbar_wrapper.dart';
import 'package:kira_auth/widgets/custom_button.dart';
import 'package:kira_auth/widgets/app_text_field.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/styles.dart';
import 'package:kira_auth/utils/encrypt.dart';
import 'package:kira_auth/models/account_model.dart';

class LoginWithMnemonicScreen extends StatefulWidget {
  @override
  _LoginWithMnemonicScreenState createState() =>
      _LoginWithMnemonicScreenState();
}

class _LoginWithMnemonicScreenState extends State<LoginWithMnemonicScreen> {
  String cachedAccountString;
  String cachedPassword;
  String password;
  String mnemonicError;

  FocusNode mnemonicFocusNode;
  TextEditingController mnemonicController;

  void getCachedPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cachedPassword = prefs.getString('password');
    });
  }

  void getCachedAccountString() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cachedAccountString = prefs.getString('accounts');
    });
  }

  @override
  void initState() {
    super.initState();
    getCachedPassword();
    getCachedAccountString();

    this.password = '';
    this.mnemonicFocusNode = FocusNode();
    this.mnemonicController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    // Set password from param
    if (arguments != null && password == '') {
      setState(() {
        password = arguments['password'];
      });
    }

    return Scaffold(
        body: AppbarWrapper(
            childWidget: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          addHeaderText(),
          addDescription(),
          addMnemonic(),
          addLoginButton(),
          addGoBackButton(),
        ],
      ),
    )));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Text(
          Strings.loginWithMnemonic,
          textAlign: TextAlign.center,
          style: TextStyle(color: KiraColors.kPrimaryColor, fontSize: 30),
        ));
  }

  Widget addDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.loginDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: KiraColors.kYellowColor, fontSize: 18),
          ))
        ]));
  }

  Widget addMnemonic() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Strings.mnemonicWords,
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: MediaQuery.of(context).size.width *
                      (smallScreen(context) ? 1 : 0.45),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    focusNode: mnemonicFocusNode,
                    controller: mnemonicController,
                    textInputAction: TextInputAction.next,
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
                        fontSize: 20.0,
                        color: KiraColors.kBrownColor,
                        fontFamily: 'NunitoSans'),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  alignment: AlignmentDirectional(0, 0),
                  margin: EdgeInsets.only(top: 3),
                  child: Text(this.mnemonicError == null ? "" : mnemonicError,
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

  Widget addLoginButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('log_in'),
          text: Strings.login,
          height: 44.0,
          onPressed: () {
            String mnemonic = mnemonicController.text;

            // Check if mnemonic is valid
            if (bip39.validateMnemonic(mnemonic) == false) {
              setState(() {
                mnemonicError = "Invalid Mnemonic";
              });
              return;
            }

            List<int> bytes = utf8.encode(password);

            // Get hash value of password and use it to encrypt mnemonic
            var hashDigest = Blake256().update(bytes).digest();
            String secretKey = String.fromCharCodes(hashDigest);

            if (cachedAccountString != null) {
              var array = cachedAccountString.split('---');

              for (int index = 0; index < array.length; index++) {
                if (array[index] != '') {
                  AccountData account = AccountData.fromString(array[index]);
                  if (decryptAESCryptoJS(account.checksum, secretKey) ==
                      'kira') {
                    setPassword(password);
                  }
                }
              }
            }

            // Navigator.pushReplacementNamed(context, '/');
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addGoBackButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.62 : 0.25),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('go_back'),
          text: Strings.back,
          height: 44.0,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }
}
