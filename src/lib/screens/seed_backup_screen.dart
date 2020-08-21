import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
// import 'package:base32/base32.dart';
import 'package:blake_hash/blake_hash.dart';
import 'package:kira_auth/utils/encrypt.dart';
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
  String _secretKey;
  String _encryptedMnemonic;
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
      List<int> bytes = utf8.encode(arguments['password']);
      var hashDigest = Blake256().update(bytes).digest();
      _secretKey = String.fromCharCodes(hashDigest);

      _encryptedMnemonic = encryptAESCryptoJS(_mnemonic, _secretKey);
      // String decrypted = decryptAESCryptoJS(_encryptedMnemonic, _secretKey);
      seedPhraseController..text = _encryptedMnemonic;

      // var encodedString = base32.encode(bytes);
      // var decodedString = base32.decodeAsString(encodedString);
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
              addExportButton(),
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
                    controller: seedPhraseController..text = _encryptedMnemonic,
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
                    enabled: false,
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
                ),
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

  Widget addExportButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.12 : 0.12),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('export'),
          text: Strings.export,
          height: 24.0,
          onPressed: () {},
          backgroundColor: KiraColors.kGrayColor,
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
