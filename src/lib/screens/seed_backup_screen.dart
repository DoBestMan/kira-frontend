// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipboard/clipboard.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/blocs/export.dart';

class SeedBackupScreen extends StatefulWidget {
  final String password;
  SeedBackupScreen({this.password}) : super();

  @override
  _SeedBackupScreenState createState() => _SeedBackupScreenState();
}

class _SeedBackupScreenState extends State<SeedBackupScreen> {
  Account currentAccount;
  String mnemonic;
  bool copied, exportEnabled;
  List<String> wordList = [];

  FocusNode seedPhraseNode;
  TextEditingController seedPhraseController;

  @override
  void initState() {
    super.initState();
    // removeCachedAccount();

    if (mounted) {
      setState(() {
        if (BlocProvider.of<AccountBloc>(context).state.currentAccount != null) {
          currentAccount = BlocProvider.of<AccountBloc>(context).state.currentAccount;
          mnemonic = decryptAESCryptoJS(currentAccount.encryptedMnemonic, currentAccount.secretKey);
          wordList = mnemonic.split(' ');
        }
      });
    }

    copied = false;
    exportEnabled = false;
    seedPhraseNode = FocusNode();
    seedPhraseController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    // final Map arguments = ModalRoute.of(context).settings.arguments as Map;

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: BlocConsumer<AccountBloc, AccountState>(
            listener: (context, state) {},
            builder: (context, state) {
              return HeaderWrapper(
                childWidget: Container(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    addHeaderText(),
                    addMnemonicDescription(),
                    addMnemonic(),
                    addCopyButton(),
                    addAddressDescription(),
                    addSeedPhrase(),
                    addExportButton(),
                    addCreateNewAccount(),
                    addGoBackButton(),
                  ],
                )),
              );
            }));
  }

  Widget addHeaderText() {
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
        margin: EdgeInsets.only(bottom: 30, right: 30, left: 30),
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

  Widget addAddressDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 20, top: 10),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.addressDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: KiraColors.kPrimaryColor, fontSize: 18),
          ))
        ]));
  }

  Widget addMnemonic() {
    return Container(margin: EdgeInsets.only(bottom: 30), child: Container(child: MnemonicDisplay(wordList: wordList)));
  }

  Widget addCopyButton() {
    return Container(
        width: MediaQuery.of(context).size.width * (ResponsiveWidget.isSmallScreen(context) ? 0.2 : 0.08),
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
    String bech32Address = currentAccount != null ? currentAccount.bech32Address : "";

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
                  width: MediaQuery.of(context).size.width * (ResponsiveWidget.isSmallScreen(context) ? 0.6 : 0.5),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: KiraColors.kPrimaryColor),
                      color: KiraColors.kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(25)),
                  child: AppTextField(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    focusNode: seedPhraseNode,
                    controller: seedPhraseController..text = bech32Address,
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
        width: MediaQuery.of(context).size.width * (ResponsiveWidget.isSmallScreen(context) ? 0.2 : 0.08),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('export'),
          text: Strings.export,
          height: 30.0,
          fontSize: 15,
          onPressed: exportEnabled
              ? () {
                  final text = currentAccount.toJsonString();
                  // prepare
                  final bytes = utf8.encode(text);
                  final blob = html.Blob([bytes]);
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  final anchor = html.document.createElement('a') as html.AnchorElement
                    ..href = url
                    ..style.display = 'none'
                    ..download = currentAccount.name + '.json';
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
        width: MediaQuery.of(context).size.width * (ResponsiveWidget.isSmallScreen(context) ? 0.52 : 0.27),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('create_account'),
          text: Strings.createAccount,
          height: 44.0,
          onPressed: () async {
            if (exportEnabled == false) {
              setAccountData(currentAccount.toJsonString());

              BlocProvider.of<AccountBloc>(context).add(SetCurrentAccount(currentAccount));

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
        width: MediaQuery.of(context).size.width * (ResponsiveWidget.isSmallScreen(context) ? 0.52 : 0.27),
        margin: EdgeInsets.only(bottom: 30),
        child: CustomButton(
          key: Key('back_to_login'),
          text: Strings.backToLogin,
          height: 44.0,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
          backgroundColor: KiraColors.kPrimaryColor,
        ));
  }
}
