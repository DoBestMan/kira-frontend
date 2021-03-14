// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clipboard/clipboard.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/blocs/export.dart';
import 'package:kira_auth/services/export.dart';

class SeedBackupScreen extends StatefulWidget {
  final String password;
  SeedBackupScreen({this.password}) : super();

  @override
  _SeedBackupScreenState createState() => _SeedBackupScreenState();
}

class _SeedBackupScreenState extends State<SeedBackupScreen> {
  StatusService statusService = StatusService();
  Account currentAccount;
  String mnemonic;
  bool seedCopied = false, exportEnabled = false;
  List<String> wordList = [];
  bool isNetworkHealthy = false;

  FocusNode seedPhraseNode;
  TextEditingController seedPhraseController;

  @override
  void initState() {
    super.initState();
    // removeCachedAccount();
    getNodeStatus();

    if (mounted) {
      setState(() {
        if (BlocProvider.of<AccountBloc>(context).state.currentAccount != null) {
          currentAccount = BlocProvider.of<AccountBloc>(context).state.currentAccount;
          mnemonic = decryptAESCryptoJS(currentAccount.encryptedMnemonic, currentAccount.secretKey);
          wordList = mnemonic.split(' ');
        }
      });
    }

    seedPhraseNode = FocusNode();
    seedPhraseController = TextEditingController();
  }

  @override
  void dispose() {
    seedPhraseController.dispose();
    super.dispose();
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

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocConsumer<AccountBloc, AccountState>(
            listener: (context, state) {},
            builder: (context, state) {
              return HeaderWrapper(
                isNetworkHealthy: isNetworkHealthy,
                childWidget: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 50, bottom: 50),
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            addHeaderTitle(),
                            addMnemonicDescription(),
                            addMnemonic(),
                            addCopyButton(),
                            addQrCode(),
                            addPublicAddress(),
                            addExportButton(),
                            ResponsiveWidget.isSmallScreen(context) ? addButtonsSmall() : addButtonsBig(),
                          ],
                        ))),
              );
            }));
  }

  Widget addHeaderTitle() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Text(
          Strings.mnemonicWords,
          textAlign: TextAlign.left,
          style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
        ));
  }

  Widget addMnemonicDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(children: <Widget>[
          Expanded(
              child: Text(
            Strings.seedPhraseDescription,
            textAlign: TextAlign.left,
            style: TextStyle(color: KiraColors.green3, fontSize: 18),
          ))
        ]));
  }

  Widget addMnemonic() {
    return Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Container(
            child: MnemonicDisplay(
          rowNumber: ResponsiveWidget.isSmallScreen(context) ? 8 : 6,
          wordList: wordList,
          isCopied: seedCopied,
        )));
  }

  Widget addCopyButton() {
    return Container(
        margin: EdgeInsets.only(bottom: 60),
        alignment: Alignment.centerLeft,
        child: CustomButton(
          key: Key('copy'),
          text: seedCopied ? Strings.copied : Strings.copy,
          width: 130,
          height: 36.0,
          style: 1,
          fontSize: 14,
          onPressed: () {
            FlutterClipboard.copy(mnemonic).then((value) => {
                  setState(() {
                    seedCopied = !seedCopied;
                  })
                });
          },
        ));
  }

  Widget addPublicAddress() {
    String bech32Address = currentAccount != null ? currentAccount.bech32Address : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          hintText: Strings.publicAddress,
          labelText: Strings.publicAddress,
          focusNode: seedPhraseNode,
          controller: seedPhraseController..text = bech32Address,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          autocorrect: false,
          keyboardType: TextInputType.text,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18.0,
            color: KiraColors.white,
            fontFamily: 'NunitoSans',
          ),
        ),
      ],
    );
  }

  Widget addQrCode() {
    return Container(
        margin: EdgeInsets.only(bottom: 60),
        alignment: Alignment.center,
        child: Container(
          width: 180,
          height: 180,
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          padding: EdgeInsets.all(0),
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: new Border.all(
              color: KiraColors.kPurpleColor,
              width: 3,
            ),
          ),
          // dropdown below..
          child: QrImage(
            data: currentAccount != null ? mnemonic : '',
            embeddedImage: AssetImage(Strings.logoImage),
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size(80, 80),
            ),
            version: QrVersions.auto,
            size: 300,
          ),
        ));
  }

  Widget addExportButton() {
    return Container(
        margin: EdgeInsets.only(top: 8, bottom: 60),
        alignment: Alignment.centerLeft,
        child: InkWell(
            onTap: exportEnabled
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
            child: Text(
              Strings.exportToKeyFile,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: exportEnabled ? KiraColors.green3 : KiraColors.kGrayColor.withOpacity(0.3),
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            )));
  }

  Widget addButtonsSmall() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            exportEnabled
                ? Container()
                : CustomButton(
                    key: Key('create_account'),
                    text: Strings.createNewAccount,
                    height: 60,
                    style: 2,
                    onPressed: () {
                      if (exportEnabled == false) {
                        setAccountData(currentAccount.toJsonString());
                        BlocProvider.of<AccountBloc>(context).add(SetCurrentAccount(currentAccount));
                        BlocProvider.of<ValidatorBloc>(context).add(GetCachedValidators(currentAccount.hexAddress));
                        setState(() {
                          exportEnabled = true;
                        });
                      }
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
              key: Key('back_to_login'),
              text: Strings.back,
              width: 250,
              height: 65,
              style: 1,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            exportEnabled
                ? Container()
                : CustomButton(
                    key: Key('create_account'),
                    text: Strings.createNewAccount,
                    width: 250,
                    height: 65,
                    style: 2,
                    onPressed: () {
                      if (exportEnabled == false) {
                        setAccountData(currentAccount.toJsonString());
                        BlocProvider.of<AccountBloc>(context).add(SetCurrentAccount(currentAccount));
                        BlocProvider.of<ValidatorBloc>(context).add(GetCachedValidators(currentAccount.hexAddress));
                        setState(() {
                          exportEnabled = true;
                        });
                      }
                    },
                  ),
          ]),
    );
  }
}
