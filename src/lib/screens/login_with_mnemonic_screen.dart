import 'package:flutter/material.dart';
import 'package:kira_auth/widgets/appbar_wrapper.dart';
import 'package:kira_auth/widgets/custom_button.dart';
import 'package:kira_auth/widgets/app_text_field.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginWithMnemonicScreen extends StatefulWidget {
  @override
  _LoginWithMnemonicScreenState createState() =>
      _LoginWithMnemonicScreenState();
}

class _LoginWithMnemonicScreenState extends State<LoginWithMnemonicScreen> {
  String _mnemonic;
  String cachedPassword;

  FocusNode seedPhraseNode;
  TextEditingController seedPhraseController;

  void getCachedPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cachedPassword = prefs.getString('password');
    });
  }

  @override
  void initState() {
    super.initState();
    getCachedPassword();

    this.seedPhraseNode = FocusNode();
    this.seedPhraseController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
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
        margin: EdgeInsets.only(bottom: 40),
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
                    focusNode: seedPhraseNode,
                    controller: seedPhraseController..text = _mnemonic,
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
                    autocorrect: false,
                    onChanged: (String newText) {
                      this._mnemonic = newText;
                      print(this._mnemonic);
                    },
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0,
                        color: KiraColors.kBrownColor,
                        fontFamily: 'NunitoSans'),
                  ),
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
            //TODO Login With Mnemonic Implementation
            if (cachedPassword != null) {}

            Navigator.pushReplacementNamed(context, '/');
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
