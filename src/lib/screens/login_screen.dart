import 'package:flutter/material.dart';
import 'package:kira_auth/widgets/appbar_wrapper.dart';
import 'package:kira_auth/widgets/custom_button.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/styles.dart';
import 'package:kira_auth/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String networkId;
  String _mnemonic;

  FocusNode seedPhraseNode;
  TextEditingController seedPhraseController;

  @override
  void initState() {
    super.initState();

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
          addNetworkId(context),
          addSeedPhrase(),
          addCreateNewAccount(),
          addLoginWithMnemonic(),
          addLoginWithKeyFile(),
        ],
      ),
    )));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Text(
          Strings.login,
          style: TextStyle(color: KiraColors.kPrimaryColor, fontSize: 30),
        ));
  }

  Widget addCreateNewAccount() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.32 : 0.22),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('create_account'),
          text: Strings.createNewAccount,
          height: 44.0,
          onPressed: () {
            Navigator.pushNamed(context, '/create-account');
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addSeedPhrase() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Strings.seedPhrase,
                    style: TextStyle(
                        color: KiraColors.kPurpleColor, fontSize: 20)),
                Container(
                  width: MediaQuery.of(context).size.width *
                      (smallScreen(context) ? 0.6 : 0.4),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
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

  Widget addLoginWithMnemonic() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.32 : 0.22),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('login_with_mnemonic'),
          text: Strings.loginWithMnemonic,
          height: 44.0,
          onPressed: () {
            print("Strings.loginWithMnemonic");
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addLoginWithKeyFile() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.32 : 0.22),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('login_with_keyfile'),
          text: Strings.loginWithKeyFile,
          height: 44.0,
          onPressed: () {
            print("Strings.loginWithKeyFile");
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addNetworkId(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(Strings.networkId,
                style: TextStyle(color: KiraColors.kPurpleColor, fontSize: 20)),
            Container(
                width: 250,
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                    border:
                        Border.all(width: 2, color: KiraColors.kPrimaryColor),
                    color: KiraColors.kPrimaryLightColor,
                    borderRadius: BorderRadius.circular(20)),
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
                        items: <String>['One', 'Two', 'Three', 'Four']
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
                ))
          ],
        ));
  }
}
