// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:clipboard/clipboard.dart';
import 'package:blake_hash/blake_hash.dart';
import 'package:kira_auth/utils/encrypt.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/strings.dart';
import 'package:kira_auth/utils/styles.dart';
import 'package:kira_auth/utils/cache.dart';
import 'package:kira_auth/models/account_model.dart';
import 'package:kira_auth/widgets/appbar_wrapper.dart';
import 'package:kira_auth/widgets/custom_button.dart';
import 'package:kira_auth/widgets/app_text_field.dart';
import 'package:kira_auth/widgets/mnemonic_display.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeedBackupScreen extends StatefulWidget {
  final String password;
  SeedBackupScreen({this.password}) : super();

  @override
  _SeedBackupScreenState createState() => _SeedBackupScreenState();
}

class _SeedBackupScreenState extends State<SeedBackupScreen> {
  AccountData accountData;
  String cachedAccountString;
  String mnemonic;
  bool copied, exportEnabled;
  List<String> wordList;

  FocusNode seedPhraseNode;
  TextEditingController seedPhraseController;

  void getAccountData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cachedAccountString = prefs.getString('accounts');
    });
  }

  @override
  void initState() {
    super.initState();
    getAccountData();

    accountData = new AccountData(
      name: 'My Account',
      version: 'v0.0.1',
      algorithm: 'AES-256',
      secretKey: '',
      encryptedMnemonic: '',
      data: '',
    );

    this.mnemonic = bip39.generateMnemonic();
    this.wordList = mnemonic.split(' ');
    this.copied = false;
    this.exportEnabled = false;
    this.seedPhraseNode = FocusNode();
    this.seedPhraseController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    // Get password from param
    if (arguments != null && accountData.encryptedMnemonic == '') {
      List<int> bytes = utf8.encode(arguments['password']);

      // Get hash value of password and use it to encrypt mnemonic
      var hashDigest = Blake256().update(bytes).digest();

      setState(() {
        accountData.secretKey = String.fromCharCodes(hashDigest);
        // Encrypt Mnemonic with AES-256 algorithm
        accountData.encryptedMnemonic =
            encryptAESCryptoJS(mnemonic, accountData.secretKey);
        accountData.name = arguments['accountName'];
      });

      // String decrypted = decryptAESCryptoJS(_encryptedMnemonic, _secretKey);
      seedPhraseController..text = accountData.encryptedMnemonic;
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
              addMnemonicDescription(),
              addMnemonic(),
              addCopyButton(),
              addSeedDescription(),
              addSeedPhrase(),
              addExportButton(),
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
          Strings.mnemonicWords,
          textAlign: TextAlign.center,
          style: TextStyle(color: KiraColors.kPrimaryColor, fontSize: 30),
        ));
  }

  Widget addMnemonicDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        padding: EdgeInsets.symmetric(horizontal: 0),
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
        margin: EdgeInsets.only(bottom: 30),
        child: Container(child: MnemonicDisplay(wordList: wordList)));
  }

  Widget addCopyButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.2 : 0.08),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('copy'),
          text: copied ? Strings.copied : Strings.copy,
          height: 30.0,
          fontSize: 15,
          onPressed: () {
            FlutterClipboard.copy(mnemonic).then((value) => {
                  setState(() {
                    copied = !copied;
                  })
                });
          },
          backgroundColor: copied ? KiraColors.kYellowColor : KiraColors.green2,
        ));
  }

  Widget addSeedPhrase() {
    return Container(
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width *
                      (smallScreen(context) ? 0.6 : 0.5),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    focusNode: seedPhraseNode,
                    controller: seedPhraseController
                      ..text = accountData.encryptedMnemonic,
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
                    readOnly: true,
                    autocorrect: false,
                    onChanged: null,
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

  Widget addExportButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.2 : 0.08),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('export'),
          text: Strings.export,
          height: 30.0,
          fontSize: 15,
          onPressed: exportEnabled
              ? () {
                  final text = accountData.toJsonString();
                  // prepare
                  final bytes = utf8.encode(text);
                  final blob = html.Blob([bytes]);
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  final anchor =
                      html.document.createElement('a') as html.AnchorElement
                        ..href = url
                        ..style.display = 'none'
                        ..download = accountData.name + '.json';
                  html.document.body.children.add(anchor);

                  // download
                  anchor.click();

                  // cleanup
                  html.document.body.children.remove(anchor);
                  html.Url.revokeObjectUrl(url);
                }
              : null,
          backgroundColor: KiraColors.green2,
        ));
  }

  Widget addCreateNewAccount() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.52 : 0.27),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('create_account'),
          text: Strings.createAccount,
          height: 44.0,
          onPressed: () async {
            if (accountData.encryptedMnemonic != '') {
              setAccountData(accountData.toJsonString());
              setState(() {
                exportEnabled = true;
              });
            }
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }

  Widget addGoBackButton() {
    return Container(
        width: MediaQuery.of(context).size.width *
            (smallScreen(context) ? 0.52 : 0.27),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('back_to_login'),
          text: Strings.backToLogin,
          height: 44.0,
          onPressed: () {
            Navigator.of(context).pop();
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }
}
