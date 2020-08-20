import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:blake2/blake2.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/styles.dart';
import 'package:kira_auth/widgets/appbar_wrapper.dart';
import 'package:kira_auth/widgets/custom_button.dart';
import 'package:kira_auth/widgets/app_text_field.dart';
import 'package:kira_auth/widgets/mnemonic_display.dart';

class SeedBackupScreen extends StatefulWidget {
  final String password;

  SeedBackupScreen({this.password}) : super();

  @override
  _SeedBackupScreenState createState() => _SeedBackupScreenState();
}

class _SeedBackupScreenState extends State<SeedBackupScreen> {
  String key;
  String seed;
  String _mnemonic;
  List<String> wordList;

  FocusNode seedPhraseNode;
  TextEditingController seedPhraseController;

  @override
  void initState() {
    super.initState();

    this._mnemonic = bip39.generateMnemonic();
    this.wordList = _mnemonic.split(' ');

    this.seedPhraseNode = FocusNode();
    this.seedPhraseController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    if (arguments != null) {
      key = arguments['password'];
      print(key);
      String salt = '39b69017';
      const String personalization = '4d97847f';

      final Blake2b blake2b = Blake2b(
        key: Uint8List.fromList(key.codeUnits),
        salt: Uint8List.fromList(salt.codeUnits),
        personalization: Uint8List.fromList(personalization.codeUnits),
      );

      print("blake2b.digest()");
    }

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: AppbarWrapper(
            childWidget: Container(
          padding: const EdgeInsets.all(30.0),
          child: Container(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              addHeadText(),
              addSeedPhraseDescription(),
              addMnemonic(),
              addSeedDescription(),
              addSeedPhrase(),
              addCreateNewAccount(),
              addGoBackButton(),
            ],
          )),
        )));
  }

  Widget addHeadText() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Text(
          Strings.seedPhrase,
          style: TextStyle(color: KiraColors.kPrimaryColor, fontSize: 30),
        ));
  }

  Widget addSeedPhraseDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        padding: EdgeInsets.symmetric(horizontal: 50),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.seedPhraseDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: KiraColors.kYellowColor, fontSize: 18),
          ))
        ]));
  }

  Widget addSeedDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30, top: 20),
        padding: EdgeInsets.symmetric(horizontal: 50),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.seedDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: KiraColors.kYellowColor, fontSize: 18),
          ))
        ]));
  }

  Widget addMnemonic() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 30),
        child: Container(child: MnemonicDisplay(wordList: wordList)));
  }

  Widget addSeedPhrase() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                    onChanged: (String newText) {},
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0,
                        color: KiraColors.kBrownColor,
                        fontFamily: 'NunitoSans'),
                  ),
                )
              ],
            ),
          ],
        ));
  }

  Widget addCreateNewAccount() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.32 : 0.22),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('create_account'),
          text: Strings.createAccount,
          height: 44.0,
          onPressed: () async {
            print("Create New Account");
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addGoBackButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.32 : 0.22),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('go_back'),
          text: Strings.back,
          height: 44.0,
          onPressed: () {
            Navigator.of(context).pop();
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }
}
